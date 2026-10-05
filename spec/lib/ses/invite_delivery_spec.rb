# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ses::InviteDelivery do
  it "sends through the dualstack SES endpoint when a configuration set is set" do
    original = ENV["SES_CONFIGURATION_SET"]
    ENV["SES_CONFIGURATION_SET"] = "parties-invites"

    endpoint = URI.parse("https://email.us-east-1.api.aws")
    config = double(endpoint: endpoint, http_open_timeout: 15, http_read_timeout: 60)
    client = instance_double(Aws::SESV2::Client, config: config)
    expect(Aws::SESV2::Client).to receive(:new).with(
      region: "us-east-1",
      use_dualstack_endpoint: true
    ).and_return(client)
    expect(client).to receive(:send_email).with(
      hash_including(configuration_set_name: "parties-invites")
    ).and_return(double(message_id: "ses-message-1"))

    resolver = instance_double(Resolv::DNS)
    allow(Resolv::DNS).to receive(:new).and_return(resolver)
    allow(resolver).to receive(:getresources).and_return([])

    mail = Mail.new(from: "host@example.com", to: "guest@example.com", subject: "Hi", body: "Hi")
    message_id = described_class.deliver!(Struct.new(:message).new(mail), tags: { "user_id" => "1", "invite_send_id" => "9" })

    expect(message_id).to eq("ses-message-1")
  ensure
    ENV["SES_CONFIGURATION_SET"] = original
  end
end
