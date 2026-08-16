# frozen_string_literal: true

require "rails_helper"

RSpec.describe BannedEmail do
  it "normalizes email to lowercase" do
    record = described_class.ban!("  Caps@Example.COM ")
    expect(record.email).to eq("caps@example.com")
  end

  it "reports whether an email is banned" do
    described_class.ban!("blocked@example.com")
    expect(described_class.banned?("Blocked@Example.com")).to be(true)
    expect(described_class.banned?("other@example.com")).to be(false)
  end
end
