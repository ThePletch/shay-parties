require "rails_helper"

RSpec.describe "events/_rsvps" do
  it "shows who is going and summarizes the other responses" do
    event = FactoryBot.create(:event)
    FactoryBot.create_list(:attendance, 2, event: event, rsvp_status: "Yes")
    FactoryBot.create_list(:attendance, 1, event: event, rsvp_status: "No")

    render("events/rsvps", event: event)

    expect(rendered).to have_css(".going-count", text: "2 going")
    expect(rendered).to have_css(".other-rsvps", text: "0 maybe · 1 can’t come")
  end

  it "shows a row for each person going" do
    event = FactoryBot.create(:event)

    attendee_a = FactoryBot.create(:user, name: "Argle")
    attendee_b = FactoryBot.create(:user, name: "Bargle")

    [attendee_a, attendee_b].each do |attendee|
      FactoryBot.create(:attendance, event: event, attendee: attendee)
    end

    render("events/rsvps", event: event)

    expect(rendered).to have_css(".going-list", text: attendee_a.name)
    expect(rendered).to have_css(".going-list", text: attendee_b.name)
  end
end
