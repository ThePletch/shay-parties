# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:target) { FactoryBot.create(:user, name: "Target User", email: "target@example.com") }

  describe "authorization" do
    it "redirects non-admins away from the index" do
      sign_in FactoryBot.create(:user)
      get :index
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t("admin.rejection.not_admin"))
    end

    it "redirects guests to sign in" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET #index" do
    before { sign_in admin }

    it "lists users" do
      target
      get :index
      expect(response).to be_successful
      expect(assigns(:users)).to include(target, admin)
    end

    it "filters by search query" do
      other = FactoryBot.create(:user, name: "Other Person", email: "other@example.com")
      get :index, params: { q: "target@" }
      expect(assigns(:users)).to include(target)
      expect(assigns(:users)).not_to include(other)
    end

    it "filters by role" do
      get :index, params: { role: "admin" }
      expect(assigns(:users)).to include(admin)
      expect(assigns(:users)).not_to include(target)
    end
  end

  describe "moderation actions" do
    before { sign_in admin }

    it "suspends a user" do
      post :suspend, params: { id: target.to_param }
      expect(target.reload).to be_suspended
      expect(response).to redirect_to(admin_user_path(target))
    end

    it "bans a user with a reason" do
      post :ban, params: { id: target.to_param, reason: "spam" }
      expect(target.reload).to be_banned
      expect(BannedEmail.find_by!(email: target.email).reason).to eq("spam")
    end

    it "promotes and demotes a user" do
      post :promote, params: { id: target.to_param }
      expect(target.reload.role).to eq("admin")

      post :demote, params: { id: target.to_param }
      expect(target.reload.role).to eq("user")
    end

    it "rejects demoting a superadmin" do
      superadmin = FactoryBot.create(:user, :superadmin)
      post :demote, params: { id: superadmin.to_param }
      expect(superadmin.reload).to be_superadmin
      expect(flash[:alert]).to eq(I18n.t("admin.users.errors.cannot_demote_superadmin"))
    end

    it "rejects banning an admin until demoted" do
      other_admin = FactoryBot.create(:user, :admin)
      post :ban, params: { id: other_admin.to_param }
      expect(other_admin.reload.role).to eq("admin")
      expect(flash[:alert]).to eq(I18n.t("admin.users.errors.must_demote_admin_first"))
    end

    it "rejects self-demotion" do
      post :demote, params: { id: admin.to_param }
      expect(admin.reload.role).to eq("admin")
      expect(flash[:alert]).to eq(I18n.t("admin.users.errors.cannot_moderate_self"))
    end
  end
end
