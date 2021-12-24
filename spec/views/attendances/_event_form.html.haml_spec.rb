require "rails_helper"

RSpec.describe "attendances/event_form" do
  it "does not prompt signed in users for name and email"
  it "prompts guests for name and email"
  it "displays name and email for already RSVPed guests"
  it "shows all attendance types as options"
end
