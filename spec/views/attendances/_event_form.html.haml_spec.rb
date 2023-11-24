require "rails_helper"

RSpec.describe "attendances/event_form" do
  it "does not prompt signed in users for name and email" do
    attendance = FactoryBot.create(:attendance)

    render('attendances/event_form', attendance: attendance, current_user: attendance.attendee)

    expect(rendered).not_to have_selector('#attendance_attendee_attributes_name')
    expect(rendered).not_to have_selector('#attendance_attendee_attributes_email')
  end

  it "prompts guests for name and email" do
    event = FactoryBot.create(:event)
    render('attendances/event_form', event: event, attendance: Attendance.new(event: event))

    expect(rendered).to have_selector('#attendance_attendee_attributes_name')
    expect(rendered).to have_selector('#attendance_attendee_attributes_email')
  end

  it "displays name and email for already RSVPed guests" do
    attendance = FactoryBot.create(:guest_attendance)
    render('attendances/event_form', attendance: attendance, current_user: attendance.attendee)

    expect(rendered).to have_selector('#attendance_attendee_attributes_name') do |field|
      expect(field['value']).to eq attendance.attendee.name
    end

    expect(rendered).to have_selector('#attendance_attendee_attributes_email') do |field|
      expect(field['value']).to eq attendance.attendee.email
    end
  end

  it "shows all attendance types as options" do
    event = FactoryBot.create(:event)
    render('attendances/event_form', event: event, attendance: Attendance.new(event: event))
    expect(rendered).to have_select(
      'attendance[rsvp_status]',
      options: [
        'No RSVP',
        'Yes',
        'Maybe',
        'No',
      ]
    )
  end
end
