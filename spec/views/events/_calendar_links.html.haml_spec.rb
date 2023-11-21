require "rails_helper"

RSpec.describe "events/_calendar_links" do
  it "hides from users not RSVPed" do
    render(
      'events/calendar_links',
      attendee: FactoryBot.create(:guest),
      event: EventDecorator.decorate(FactoryBot.create(:event)),
    )

    expect(rendered).to eq ""
  end

  it "shows to RSVPed users" do
    attendance = FactoryBot.create(:attendance)

    render(
      'events/calendar_links',
      attendee: attendance.attendee,
      event: EventDecorator.decorate(attendance.event),
    )

    expect(rendered).to have_selector('.calendar-links')
  end
end
