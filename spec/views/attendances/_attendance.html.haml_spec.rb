require "rails_helper"

RSpec.describe "attendances/attendance" do
  it "displays a gravatar for the user" do
    attendance = FactoryBot.build(:attendance)

    render('attendances/attendance', attendance: attendance)

    expect(rendered).to have_selector('img.avatar') do |e|
      expect(e['src']).to match('secure.gravatar.com/avatar/')
    end
  end

  it "shows if the attendee is a guest" do
    attendance = FactoryBot.build(:guest_attendance)

    render('attendances/attendance', attendance: attendance)

    # We don't label guest accounts right now
    expect(rendered).to have_selector('.is-guest', exact_text: '')
  end

  it "shows if the attendee is a host" do
    event = FactoryBot.build(:event)
    attendance = FactoryBot.build(:attendance, event: event, attendee: event.owner)

    render('attendances/attendance', attendance: attendance)

    expect(rendered).to have_selector('.is-host', text: 'Host')
  end

  it "shows a delete button to the host" do
    event = FactoryBot.create(:event)
    attendance = FactoryBot.create(:attendance, event: event)

    render('attendances/attendance', attendance: attendance, current_user: event.owner)

    expect(rendered).to have_selector('.remove-attendance')
  end

  it "does not show a delete button to other people" do
    attendance = FactoryBot.create(:attendance)

    render('attendances/attendance', attendance: attendance)

    expect(rendered).not_to have_selector('.remove-attendance')
  end

  it "shows emails to the host" do
    event = FactoryBot.create(:event)
    attendance = FactoryBot.create(:attendance, event: event)

    render('attendances/attendance', attendance: attendance, current_user: event.owner)

    expect(rendered).to have_selector('.attendee-email', text: attendance.attendee.email)
  end

  it "hides emails from guests" do
    event = FactoryBot.create(:event)
    attendance = FactoryBot.create(:attendance, event: event)

    render('attendances/attendance', attendance: attendance, current_user: attendance.attendee)

    expect(rendered).not_to have_selector('.attendee-email')
  end
end
