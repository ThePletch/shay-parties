require "rails_helper"

RSpec.describe "addresses/_show" do
  it "renders nothing for a blank address" do
    render('addresses/show', address: Address.new)

    expect(rendered).not_to have_selector('address')
  end
  it "renders only the parts that are present" do
    # n.b. BC stands for Buttish Columbia
    address = Address.new(street: '123 Butt St', city: 'Buttsville', state: 'BC')

    render('addresses/show', address: address)

    expect(rendered).to have_selector('address', text: /123 Butt St\sButtsville, BC/)
  end
end
