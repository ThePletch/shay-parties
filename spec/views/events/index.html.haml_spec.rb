require "rails_helper"

RSpec.describe "events/index" do
  it "hides secret events from unauthed users"
  it "hides secret events from authed users without RSVP"
  it "shows secret events to the host"
  it "shows secret events to user attendees"
  it "shows secret events to guest attendees"
  it "shows non-secret events to everybody"

  context "my events" do
    it "shows only events being hosted by the user"
  end
end
