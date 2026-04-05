require 'rails_helper'

describe Event do

  it "lets you save a valid event" do
    huge_party = Event.new(
      start_time: DateTime.iso8601('2019-05-01T17:00:00+05:00'),
      end_time: DateTime.iso8601('2019-05-01T17:02:00+05:00')
    )
    expect(huge_party).to be_valid
  end

  it "rejects events that start after they end" do
    time_travel_convention = Event.new(start_time: Time.current, end_time: Time.current - 1)
    expect(time_travel_convention).not_to be_valid
    expect(time_travel_convention.errors.messages.keys).to include :end_time
  end
end
