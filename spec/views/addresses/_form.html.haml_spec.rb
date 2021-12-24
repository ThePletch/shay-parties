require "rails_helper"

RSpec.describe "addresses/_form" do
  it "shows a prompt for prior addresses" do
    first_addr = FactoryBot.create(:address)
    second_addr = FactoryBot.create(:address)
    assign(:prior_addresses, [first_addr, second_addr])

    render

    expect(rendered).to match /#{first_addr.street}/
    expect(rendered).to match /#{first_addr.street2}/
    expect(rendered).to match /#{second_addr.street}/
    expect(rendered).to match /#{second_addr.street2}/
  end
  it "does not list prior addresses if none provided"
  it "lists US states as options"
end
