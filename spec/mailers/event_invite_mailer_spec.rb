# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventInviteMailer, type: :mailer do
  it "includes the host message, event link, and reply-to" do
    host = FactoryBot.create(:user, name: "Host Name")
    event = FactoryBot.create(:event, owner: host, title: "Dance Party")

    mail = described_class.invite(
      event: event,
      host: host,
      recipient_email: "ada@example.com",
      message: "Bring snacks"
    )

    expect(mail.to).to eq(["ada@example.com"])
    expect(mail.reply_to).to eq([host.email])
    expect(mail.subject).to include("Dance Party")
    expect(mail.subject).to include("Host Name")
    body = mail.body.encoded
    expect(body).to include("Parties for All")
    expect(body).to include("Dance Party")
    expect(body).to include("The host, Host Name, included this note:")
    expect(body).to include("Bring snacks")
    expect(body).to include("RSVP")
    expect(body).to include("use this link:")
    expect(body).to include(event.to_param)
    expect(body).not_to include("Hi Ada")
  end

  it "omits the host note preface when the note is blank" do
    host = FactoryBot.create(:user, name: "Host Name")
    event = FactoryBot.create(:event, owner: host, title: "Dance Party")

    mail = described_class.invite(
      event: event,
      host: host,
      recipient_email: "ada@example.com",
      message: "  "
    )

    expect(mail.body.encoded).not_to include("included this note")
    expect(mail.body.encoded).to include("RSVP")
  end
end
