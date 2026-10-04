# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sns::Https do
  it "fetches sns.amazonaws.com URLs from the IPv6 api.aws endpoint" do
    uri = URI("https://sns.us-east-1.amazonaws.com/SimpleNotificationService-abc.pem?Action=ConfirmSubscription&Token=t")
    address = instance_double(Addrinfo, ip_address: "2600:1f70:8000:410::1")
    allow(Addrinfo).to receive(:getaddrinfo).and_return([address])

    http = instance_double(Net::HTTP)
    expect(http).to receive(:request) do |request|
      expect(request.path).to eq("/SimpleNotificationService-abc.pem?Action=ConfirmSubscription&Token=t")
      Net::HTTPOK.new("1.1", "200", "OK")
    end
    expect(Net::HTTP).to receive(:start).with(
      "sns.us-east-1.api.aws",
      443,
      hash_including(ipaddr: "2600:1f70:8000:410::1", use_ssl: true)
    ).and_yield(http)

    described_class.get(uri)
  end
end
