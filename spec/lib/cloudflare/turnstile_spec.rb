require "rails_helper"

describe Cloudflare::Turnstile do
  around do |example|
    original_site = ENV["TURNSTILE_SITE_KEY"]
    original_secret = ENV["TURNSTILE_SECRET_KEY"]
    example.run
  ensure
    ENV["TURNSTILE_SITE_KEY"] = original_site
    ENV["TURNSTILE_SECRET_KEY"] = original_secret
  end

  describe ".enabled?" do
    it "is false when keys are missing" do
      ENV["TURNSTILE_SITE_KEY"] = nil
      ENV["TURNSTILE_SECRET_KEY"] = nil
      expect(described_class).not_to be_enabled
    end

    it "is true when both keys are present" do
      ENV["TURNSTILE_SITE_KEY"] = "site"
      ENV["TURNSTILE_SECRET_KEY"] = "secret"
      expect(described_class).to be_enabled
    end
  end

  describe ".verify" do
    it "bypasses verification in test when keys are unset" do
      ENV["TURNSTILE_SITE_KEY"] = nil
      ENV["TURNSTILE_SECRET_KEY"] = nil
      expect(described_class.verify(nil)).to eq(true)
    end

    it "returns false for a blank token when enabled" do
      ENV["TURNSTILE_SITE_KEY"] = "site"
      ENV["TURNSTILE_SECRET_KEY"] = "secret"
      expect(described_class.verify("")).to eq(false)
    end

    it "posts to Cloudflare and returns the success flag" do
      ENV["TURNSTILE_SITE_KEY"] = "site"
      ENV["TURNSTILE_SECRET_KEY"] = "secret"

      http_response = instance_double(Net::HTTPOK, body: '{"success":true}', is_a?: true)
      allow(http_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      expect(Net::HTTP).to receive(:post_form).and_return(http_response)

      expect(described_class.verify("tok", remote_ip: "1.2.3.4")).to eq(true)
    end
  end
end
