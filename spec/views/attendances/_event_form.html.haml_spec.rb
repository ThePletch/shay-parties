require "rails_helper"

RSpec.describe "attendances/event_form" do
  it "does not prompt signed in users for name and email" do
    attendance = FactoryBot.create(:attendance)

    render("attendances/event_form", attendance: attendance, current_user: attendance.attendee)

    expect(rendered).not_to have_selector("#attendance_attendee_attributes_name", visible: :all)
    expect(rendered).not_to have_selector("#attendance_attendee_attributes_email", visible: :all)
    expect(rendered).to have_css("form[data-rsvp-autosubmit]")
  end

  it "hides name and email until a new guest selects a response" do
    event = FactoryBot.create(:event)
    render("attendances/event_form", event: event, attendance: Attendance.new(event: event))

    expect(rendered).to have_css('[data-rsvp-identity="pending"][hidden]', visible: :all)
    expect(rendered).to have_selector("#attendance_attendee_attributes_name", visible: :all)
    expect(rendered).to have_selector("#attendance_attendee_attributes_email", visible: :all)
    expect(rendered).not_to have_css("form[data-rsvp-autosubmit]")
  end

  it "shows a saved guest as their name and email" do
    attendance = FactoryBot.create(:guest_attendance)
    render("attendances/event_form", attendance: attendance)

    expect(rendered).to have_text("#{attendance.attendee.name} · #{attendance.attendee.email}")
    expect(rendered).to have_css('[data-rsvp-identity="saved"][hidden]', visible: :all)
    expect(rendered).to have_selector("#attendance_attendee_attributes_name", visible: :all) do |field|
      expect(field["value"]).to eq attendance.attendee.name
    end
    expect(rendered).to have_selector("#attendance_attendee_attributes_email", visible: :all) do |field|
      expect(field["value"]).to eq attendance.attendee.email
    end
  end

  it "offers going, maybe, and can't as choices" do
    event = FactoryBot.create(:event)
    render("attendances/event_form", event: event, attendance: Attendance.new(event: event))

    expect(rendered).to have_field("attendance[rsvp_status]", type: "radio", with: "Yes")
    expect(rendered).to have_field("attendance[rsvp_status]", type: "radio", with: "Maybe")
    expect(rendered).to have_field("attendance[rsvp_status]", type: "radio", with: "No")
    expect(rendered).not_to have_field("attendance[rsvp_status]", type: "radio", with: "No RSVP")
  end
end
