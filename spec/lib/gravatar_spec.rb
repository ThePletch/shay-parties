require "rails_helper"

RSpec.describe Gravatar do
  it "builds an identicon gravatar URL for an email" do
    digest = Digest::MD5.hexdigest("host@example.com")

    expect(Gravatar.url("host@example.com", size: 25)).to eq(
      "https://secure.gravatar.com/avatar/#{digest}?d=identicon&s=25"
    )
  end
end
