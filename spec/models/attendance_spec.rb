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

end
