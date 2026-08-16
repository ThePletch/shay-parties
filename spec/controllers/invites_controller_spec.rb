# frozen_string_literal: true

require "rails_helper"

RSpec.describe InvitesController, type: :controller do
  let(:host) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, owner: host) }
  let(:recipients) do
    {
      "0" => { name: "Ada", email: "ada@example.com", selected: "1" },
    }
  end

  before { ActionMailer::Base.deliveries.clear }

  def send_invites(extra_recipients = recipients)
    post :create, params: {
      event_id: event.to_param,
      message: "Please come!",
      recipients: extra_recipients,
    }
  end

  describe "authorization" do
    it "does not let a non-host send invites" do
      sign_in FactoryBot.create(:user)
      expect { send_invites }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "blocks an unconfirmed host" do
      host.update!(confirmed_at: nil)
      sign_in host

      expect { send_invites }.not_to change(InviteSend, :count)
      expect(response).to redirect_to(event_path(event))
      expect(flash[:alert]).to eq(I18n.t("invite.rejection.unconfirmed"))
    end

    it "blocks a restricted host" do
      host.update!(invite_send_restricted_at: Time.current, invite_send_restriction_reason: "complaint")
      sign_in host

      expect { send_invites }.not_to change(InviteSend, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to eq(I18n.t("invite.rejection.restricted"))
    end
  end

  describe "POST #create" do
    before { sign_in host }

    it "sends invites and logs each recipient" do
      expect { send_invites }.to change(InviteSend, :count).by(1)

      expect(response).to redirect_to(event_path(event))
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq(["ada@example.com"])
      expect(mail.reply_to).to eq([host.email])
      expect(mail.body.encoded).to include("Please come!")
      expect(mail.body.encoded).to include(event.to_param)
    end

    it "rejects an over-limit batch without sending any" do
      FactoryBot.create_list(:invite_send, InviteSend::DAILY_LIMIT, user: host, event: event)

      expect { send_invites }.not_to change(InviteSend, :count)
      expect(ActionMailer::Base.deliveries).to be_empty
      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to include("0 remaining")
    end

    it "sends a batch that fits under the remaining quota" do
      FactoryBot.create_list(:invite_send, InviteSend::DAILY_LIMIT - 1, user: host, event: event)

      expect { send_invites }.to change(InviteSend, :count).by(1)
      expect(response).to redirect_to(event_path(event))
    end
  end

  describe "POST #preview" do
    before { sign_in host }

    it "renders the first recipient's invite" do
      post :preview, params: {
        event_id: event.to_param,
        message: "See you there",
        recipients: {
          "0" => { name: "Ada", email: "ada@example.com", selected: "1" },
        },
      }

      expect(response).to be_successful
      expect(response.body).to include("Ada")
      expect(response.body).to include("See you there")
      expect(response.body).to include(event.to_param)
      expect(InviteSend.count).to eq(0)
    end
  end
end
