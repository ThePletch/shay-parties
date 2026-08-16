# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sns::Verifier do
  it "returns false for a payload that is not a signed SNS message" do
    expect(described_class.authentic?("{}")).to eq(false)
    expect(described_class.authentic?("not-json")).to eq(false)
  end
end
