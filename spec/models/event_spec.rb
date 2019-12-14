require 'rails_helper'

describe Event do

  it "lets you save a valid event" do
    huge_party = Event.new(start_time: "05/01/2019 5:05 pm", end_time: "05/01/2019 5:07 pm")
    expect(huge_party).to be_valid
  end

  it "rejects events that start after they end" do
    time_travel_convention = Event.new(start_time: Time.current, end_time: Time.current - 1)
    expect(time_travel_convention).not_to be_valid
    expect(time_travel_convention.errors.messages.keys).to include :end_time
  end

  it "parses timestamps properly" do
    huge_party = Event.new(start_time: "05/01/2019 5:05 pm", end_time: "05/01/2019 5:07 pm")
    expect(huge_party).to be_valid
    expect(huge_party.start_time).to eq Time.zone.local(2019, 5, 1, 17, 5, 0)
    expect(huge_party.end_time).to eq Time.zone.local(2019, 5, 1, 17, 7, 0)
  end

end
