# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ses::NotificationProcessor do
  let(:host) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, owner: host) }
  let!(:invite_send) do
    FactoryBot.create(:invite_send, user: host, event: event, recipient_email: "ada@example.com", ses_message_id: "msg-1")
  end
  let!(:admin) { FactoryBot.create(:user, :admin) }

  before { ActionMailer::Base.deliveries.clear }

  def bounce_payload(bounce_type:, message_id:, recipient: "ada@example.com")
    {
      "eventType" => "Bounce",
      "bounce" => {
        "bounceType" => bounce_type,
        "bouncedRecipients" => [{ "emailAddress" => recipient }],
      },
      "mail" => {
        "messageId" => message_id,
        "tags" => {
          "user_id" => [host.id.to_s],
          "invite_send_id" => [invite_send.id.to_s],
        },
      },
    }
  end

  def complaint_payload(message_id:)
    {
      "eventType" => "Complaint",
      "complaint" => {
        "complainedRecipients" => [{ "emailAddress" => "ada@example.com" }],
      },
      "mail" => {
        "messageId" => message_id,
        "tags" => {
          "user_id" => [host.id.to_s],
          "invite_send_id" => [invite_send.id.to_s],
        },
      },
    }
  end

  it "emails the sender with remaining allowance on hard bounces 1 and 2" do
    described_class.process(bounce_payload(bounce_type: "Permanent", message_id: "b1"))

    expect(host.reload).not_to be_invite_send_restricted
    expect(host.hard_bounce_strikes).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([host.email])
    expect(mail.body.encoded).to include("ada@example.com")
    expect(mail.body.encoded).to include("2")

    described_class.process(bounce_payload(bounce_type: "Permanent", message_id: "b2"))
    expect(host.reload.hard_bounce_strikes).to eq(2)
    expect(host).not_to be_invite_send_restricted
    expect(ActionMailer::Base.deliveries.last.body.encoded).to include("1")
  end

  it "restricts on the third hard bounce and notifies sender plus admins" do
    described_class.process(bounce_payload(bounce_type: "Permanent", message_id: "b1"))
    described_class.process(bounce_payload(bounce_type: "Permanent", message_id: "b2"))
    ActionMailer::Base.deliveries.clear

    described_class.process(bounce_payload(bounce_type: "Permanent", message_id: "b3"))

    expect(host.reload).to be_invite_send_restricted
    expect(host.invite_send_restriction_reason).to eq("bounce_limit")
    recipients = ActionMailer::Base.deliveries.flat_map(&:to)
    expect(recipients).to include(host.email, admin.email)
  end

  it "restricts immediately on a spam complaint and notifies sender plus admins" do
    described_class.process(complaint_payload(message_id: "c1"))

    expect(host.reload).to be_invite_send_restricted
    expect(host.invite_send_restriction_reason).to eq("complaint")
    recipients = ActionMailer::Base.deliveries.flat_map(&:to)
    expect(recipients).to include(host.email, admin.email)
  end

  it "does not restrict on a soft bounce" do
    described_class.process(bounce_payload(bounce_type: "Transient", message_id: "s1"))

    expect(host.reload).not_to be_invite_send_restricted
    expect(host.hard_bounce_strikes).to eq(0)
    expect(EmailDeliveryEvent.last.bounce_type).to eq("Transient")
  end

  it "ignores duplicate SNS notifications" do
    payload = bounce_payload(bounce_type: "Permanent", message_id: "dup")
    described_class.process(payload)
    expect { described_class.process(payload) }.not_to change(EmailDeliveryEvent, :count)
  end
end
