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

  it "asks if the event should be secret" do
    event = FactoryBot.create(:event)

    render(
      'events/form',
      event: event
    )

    expect(rendered).to have_text('Make this event secret')
  end

  it "asks if the event should require COVID testing" do
    event = FactoryBot.create(:event)

    render(
      'events/form',
      event: event
    )

    expect(rendered).to have_text('Require COVID testing')
  end
end
