# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  describe "role helpers" do
    it "treats admin and superadmin as admin?" do
      expect(FactoryBot.build(:user, :admin)).to be_admin
      expect(FactoryBot.build(:user, :superadmin)).to be_admin
      expect(FactoryBot.build(:user)).not_to be_admin
    end

    it "identifies suspended and banned roles" do
      expect(FactoryBot.build(:user, :suspended)).to be_suspended
      expect(FactoryBot.build(:user, :banned)).to be_banned
    end
  end

  describe "#active_for_authentication?" do
    it "allows normal users" do
      expect(FactoryBot.create(:user)).to be_active_for_authentication
    end

    it "blocks suspended users" do
      expect(FactoryBot.create(:user, :suspended)).not_to be_active_for_authentication
    end

    it "blocks banned users" do
      expect(FactoryBot.create(:user, :banned)).not_to be_active_for_authentication
    end
  end

  describe "email denylist" do
    it "rejects signup with a banned email" do
      BannedEmail.ban!("blocked@example.com")
      user = FactoryBot.build(:user, email: "blocked@example.com")

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include(I18n.t("activerecord.errors.models.user.attributes.email.banned"))
    end

    it "rejects changing email to a banned address" do
      BannedEmail.ban!("blocked@example.com")
      user = FactoryBot.create(:user)

      user.email = "blocked@example.com"
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe "moderation" do
    let(:admin) { FactoryBot.create(:user, :admin) }
    let(:target) { FactoryBot.create(:user) }

    it "lets an admin suspend and unsuspend a user" do
      target.suspend!(actor: admin)
      expect(target.reload).to be_suspended

      target.unsuspend!(actor: admin)
      expect(target.reload.role).to eq("user")
    end

    it "bans a user and denylists their email" do
      target.ban!(actor: admin, reason: "spam")
      expect(target.reload).to be_banned
      expect(BannedEmail.banned?(target.email)).to be(true)
      expect(BannedEmail.find_by!(email: target.email).reason).to eq("spam")
    end

    it "unbans a user and removes the denylist entry" do
      target.ban!(actor: admin)
      target.unban!(actor: admin)

      expect(target.reload.role).to eq("user")
      expect(BannedEmail.banned?(target.email)).to be(false)
    end

    it "lets an admin promote and demote another user" do
      target.promote_to_admin!(actor: admin)
      expect(target.reload.role).to eq("admin")

      target.demote_from_admin!(actor: admin)
      expect(target.reload.role).to eq("user")
    end

    it "cannot demote, ban, or suspend a superadmin" do
      superadmin = FactoryBot.create(:user, :superadmin)

      expect { superadmin.demote_from_admin!(actor: admin) }.to raise_error(User::ModerationError)
      expect { superadmin.ban!(actor: admin) }.to raise_error(User::ModerationError)
      expect { superadmin.suspend!(actor: admin) }.to raise_error(User::ModerationError)
    end

    it "cannot ban or suspend an admin until demoted" do
      other_admin = FactoryBot.create(:user, :admin)

      expect { other_admin.ban!(actor: admin) }.to raise_error(User::ModerationError)
      expect { other_admin.suspend!(actor: admin) }.to raise_error(User::ModerationError)

      other_admin.demote_from_admin!(actor: admin)
      expect { other_admin.ban!(actor: admin) }.not_to raise_error
    end

    it "cannot self-demote, self-ban, or self-suspend" do
      expect { admin.demote_from_admin!(actor: admin) }.to raise_error(User::ModerationError)
      expect { admin.ban!(actor: admin) }.to raise_error(User::ModerationError)
      expect { admin.suspend!(actor: admin) }.to raise_error(User::ModerationError)
    end

    it "denylists unconfirmed_email when banning" do
      target.update_columns(unconfirmed_email: "pending@example.com")
      target.ban!(actor: admin)

      expect(BannedEmail.banned?("pending@example.com")).to be(true)
    end
  end
end
