require "rails_helper"

RSpec.describe "events/_form" do
  before do
    assign(:prior_addresses, [])
  end

  it "shows error messages if present" do
    event = FactoryBot.build(
      :event,
      start_time: Time.current,
      end_time: Time.current - 1,
    )
    event.valid?

    render(
      'events/form',
      event: event
    )

    expect(rendered).to have_selector('.invalid-feedback')
    expect(rendered).to have_selector('#error_explanation')
  end

  it "asks if the event should be secret with proper explanation text" do
    event = FactoryBot.create(:event)

    render(
      'events/form',
      event: event
    )

    expect(rendered).to have_text('Make this event secret')
    expect(rendered).to have_text("Secret events don't appear on the home page unless someone has RSVPed")
  end
end
