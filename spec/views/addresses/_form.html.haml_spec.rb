require "rails_helper"

RSpec.describe "addresses/_form" do
  it "shows a prompt for prior addresses" do
    first_addr = FactoryBot.create(:address)
    second_addr = FactoryBot.create(:address)
    assign(:prior_addresses, [first_addr, second_addr])

    render

    expect(rendered).to have_selector('option', text: /#{first_addr.street}/)
    expect(rendered).to have_selector('option', text: /#{first_addr.street2}/)
    expect(rendered).to have_selector('option', text: /#{second_addr.street}/)
    expect(rendered).to have_selector('option', text: /#{second_addr.street2}/)
  end

  it "does not list prior addresses if none provided" do
    assign(:prior_addresses, [])

    render

    expect(rendered).not_to have_css('#prior_addresses')
  end

  it "lists US states as options" do
    assign(:prior_addresses, [])

    render

    expect(rendered).to have_select('address[state]', with_options: ['Massachusetts'])
  end
end
