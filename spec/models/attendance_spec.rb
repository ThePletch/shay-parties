require 'rails_helper'

describe Attendance do

  it "accepts a valid rsvp status" do
    rsvp = FactoryBot.build(:attendance, rsvp_status: 'Yes')

    expect(rsvp).to be_valid
  end

  it "rejects invalid rsvp statuses" do
    rsvp = FactoryBot.build(:attendance, rsvp_status: "i'll let you know 20 minutes before if five of us are coming")

    expect(rsvp).not_to be_valid
  end

  it "allows creating attendances for users" do
    user = FactoryBot.create(:user)
    rsvp = FactoryBot.build(:attendance, attendee: user)

    expect(rsvp).to be_valid
  end

  it "allows creating attendances for guests" do
    guest = FactoryBot.create(:guest)
    rsvp = FactoryBot.build(:attendance, attendee: guest)

    expect(rsvp).to be_valid
    expect(rsvp.attendee).to be_a Guest
  end

  it "allows creating plus ones" do
    attendance = FactoryBot.create(:attendance)
    plus_one = FactoryBot.build(:guest_attendance, parent_attendance: attendance, event: attendance.event)

    expect(plus_one).to be_valid
  end

  it "rejects plus ones that are for a different event" do
    attendance = FactoryBot.create(:attendance)
    attendance_for_a_different_event = FactoryBot.build(:guest_attendance, parent_attendance: attendance)

    expect(attendance_for_a_different_event).not_to be_valid
  end

  it "does not allow plus ones beyond event limit" do
    event = FactoryBot.create(:event, plus_one_max: 1)
    attendance = FactoryBot.create(:attendance, event: event)
    within_limit_attendance = FactoryBot.build(:guest_attendance, event: event, parent_attendance: attendance)
    expect(within_limit_attendance).to be_valid
    within_limit_attendance.save!

    beyond_limit_attendance = FactoryBot.build(:guest_attendance, event: event, parent_attendance: attendance)
    expect(beyond_limit_attendance).not_to be_valid
  end

  it "allows no plus ones for events with plus-ones disabled" do
    event = FactoryBot.create(:event, plus_one_max: 0)
    attendance = FactoryBot.create(:attendance, event: event)
    within_limit_attendance = FactoryBot.build(:guest_attendance, event: event, parent_attendance: attendance)
    expect(within_limit_attendance).not_to be_valid
  end

  it "deletes poll responses for its event when destroyed" do
    user = FactoryBot.create(:user)
    rsvp = FactoryBot.create(:attendance, attendee: user)
    poll = FactoryBot.create(:poll, event: rsvp.event)
    response = FactoryBot.create(:poll_response, poll: poll, respondent: user)

    rsvp.destroy!

    expect(PollResponse.find_by(id: response.id)).to be_nil
  end
end
