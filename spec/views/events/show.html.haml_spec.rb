require "rails_helper"

RSpec.describe "events/show" do
  it "shows calendar links to user attendees" do
    attendance = FactoryBot.create(:attendance, rsvp_status: "Yes")

    assign(:event, EventDecorator.decorate(attendance.event))
    assign(:attendance, attendance)
    assign(:attendee, attendance.attendee)

    render

    expect(rendered).to match /Add to Google Calendar/
  end

  it "shows calendar links to guest attendees" do
    attendance = FactoryBot.create(:guest_attendance, rsvp_status: "Yes")

    assign(:event, EventDecorator.decorate(attendance.event))
    assign(:attendance, attendance)
    assign(:attendee, attendance.attendee)

    render

    expect(rendered).to match /Add to Google Calendar/
  end

  it "hides calendar links from 'no'-RSVPed attendees" do
    attendance = FactoryBot.create(:attendance, rsvp_status: "No")

    assign(:event, EventDecorator.decorate(attendance.event))
    assign(:attendance, attendance)
    assign(:attendee, attendance.attendee)

    render

    expect(rendered).not_to match /Add to Google Calendar/
  end

  it "hides calendar links if no RSVP" do
    event = FactoryBot.create(:event)
    assign(:event, EventDecorator.decorate(event))
    assign(:attendance, event.attendances.build)

    render

    expect(rendered).not_to match /Add to Google Calendar/
  end

  it "warns about COVID requirements if enabled" do
    event = FactoryBot.create(:event, requires_testing: true)
    assign(:event, EventDecorator.decorate(event))
    assign(:attendance, event.attendances.build)

    render

    expect(rendered).to have_text("negative rapid COVID test")
  end
end
