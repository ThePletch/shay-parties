require 'rails_helper'

describe MailingList do

  describe "sync_users" do
    it "links emails to users with matching emails" do
      matching_user = FactoryBot.create(:user, email: 'steve@yes.no')
      non_matching_user = FactoryBot.create(:user, email: 'steve@yes.biz')
      mailing_list = FactoryBot.create(:mailing_list, emails: ['steve@yes.no', 'what@test.good'])
      mailing_list.sync_users

      expect(mailing_list.emails.map(&:user)).to match_array [matching_user, nil]
    end

    context "force: true" do
      it "overwrites existing connections" do
        matching_user = FactoryBot.create(:user, email: 'steve@yes.no')
        non_matching_user = FactoryBot.create(:user, email: 'steve@yes.biz')
        mailing_list = FactoryBot.create(:mailing_list, emails: ['steve@yes.no'])
        mailing_list.sync_users

        expect(mailing_list.emails.first.user).to eq matching_user
        matching_user.update(email: "different@email.com")
        non_matching_user.update(email: "steve@yes.no")
        mailing_list.sync_users(force: true)

        expect(mailing_list.emails.first.user).to eq non_matching_user
      end
    end

    context "force: false" do
      it "leaves existing connections in place" do
        matching_user = FactoryBot.create(:user, email: 'steve@yes.no')
        non_matching_user = FactoryBot.create(:user, email: 'steve@yes.biz')
        mailing_list = FactoryBot.create(:mailing_list, emails: ['steve@yes.no'])
        mailing_list.sync_users

        expect(mailing_list.emails.first.user).to eq matching_user
        matching_user.update(email: "different@email.com")
        non_matching_user.update(email: "steve@yes.no")
        mailing_list.sync_users(force: false)

        expect(mailing_list.emails.first.user).to eq matching_user
      end
    end
  end
end
