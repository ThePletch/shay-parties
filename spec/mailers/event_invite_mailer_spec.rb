# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventInviteMailer, type: :mailer do
  it "includes the host message, event link, and reply-to" do
    host = FactoryBot.create(:user, name: "Host Name")
    event = FactoryBot.create(:event, owner: host, title: "Dance Party")

    mail = described_class.invite(
      event: event,
      host: host,
      recipient_name: "Ada",
      recipient_email: "ada@example.com",
      message: "Bring snacks"
    )

    expect(mail.to).to eq(["ada@example.com"])
    expect(mail.reply_to).to eq([host.email])
    expect(mail.subject).to include("Dance Party")
    expect(mail.subject).to include("Host Name")
    expect(mail.body.encoded).to include("Bring snacks")
    expect(mail.body.encoded).to include(event.to_param)
  end
end
