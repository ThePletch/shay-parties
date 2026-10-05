require "rails_helper"

RSpec.describe "events/show" do
  it "shows calendar links to user attendees" do
    attendance = FactoryBot.create(:attendance, rsvp_status: "Yes")

    assign(:event, attendance.event)
    assign(:attendance, attendance)
    assign(:attendee, attendance.attendee)

    render

    expect(rendered).to have_text("Add to calendar")
  end

  it "shows calendar links to guest attendees" do
    attendance = FactoryBot.create(:guest_attendance, rsvp_status: "Yes")

    assign(:event, attendance.event)
    assign(:attendance, attendance)
    assign(:attendee, attendance.attendee)

    render

    expect(rendered).to have_text("Add to calendar")
  end

  it "hides calendar links from 'no'-RSVPed attendees" do
    attendance = FactoryBot.create(:attendance, rsvp_status: "No")

    assign(:event, attendance.event)
    assign(:attendance, attendance)
    assign(:attendee, attendance.attendee)

    render

    expect(rendered).not_to have_text("Add to calendar")
  end

  it "hides calendar links if no RSVP" do
    event = FactoryBot.create(:event)
    assign(:event, event)
    assign(:attendance, event.attendances.build)

    render

    expect(rendered).not_to have_text("Add to calendar")
  end

  it "warns about COVID requirements if enabled" do
    event = FactoryBot.create(:event, requires_testing: true)
    assign(:event, event)
    assign(:attendance, event.attendances.build)

    render

    expect(rendered).to have_css(".badge", text: "COVID test required")
    expect(rendered).to have_css("small", text: "negative rapid COVID test")
    expect(rendered).not_to have_css(".alert")
  end
end
