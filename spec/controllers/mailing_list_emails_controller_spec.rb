require "rails_helper"

describe MailingListEmailsController do
  def login_creator
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = FactoryBot.create(:user, role: :creator)
    sign_in @user
  end

  describe "DELETE destroy" do
    it "removes one address from the owner's list" do
      login_creator
      mailing_list = FactoryBot.create(:mailing_list, user: @user, emails: ["maya@example.com", "jordan@example.com"])
      email = mailing_list.emails.find_by!(email: "maya@example.com")

      delete :destroy, params: {mailing_list_id: mailing_list.id, id: email.id}

      expect(response).to redirect_to(mailing_list_path(mailing_list))
      expect(mailing_list.emails.reload.pluck(:email)).to eq(["jordan@example.com"])
    end
  end
end