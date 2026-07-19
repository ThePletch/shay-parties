require "rails_helper"

describe Users::RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        user: {
          email: "newuser@example.com",
          name: "New User",
          password: "wordpass",
          password_confirmation: "wordpass",
        },
        "cf-turnstile-response" => "token",
      }
    end

    it "creates a user when Turnstile verification succeeds" do
      allow(Cloudflare::Turnstile).to receive(:verify).and_return(true)

      expect {
        post :create, params: valid_params
      }.to change(User, :count).by(1)

      user = User.find_by!(email: "newuser@example.com")
      expect(user).not_to be_confirmed
      expect(user.name).to eq("New User")
    end

    it "rejects registration when Turnstile verification fails" do
      allow(Cloudflare::Turnstile).to receive(:verify).and_return(false)

      expect {
        post :create, params: valid_params
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(assigns(:user).errors[:base]).to include(I18n.t("turnstile.failed"))
    end
  end
end
