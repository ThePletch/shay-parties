require "rails_helper"

RSpec.describe "dynamic nested records", type: :system do
  it "creates a poll and example response added from the event form" do
    event = FactoryBot.create(:event)
    sign_in event.owner
    visit edit_event_path(event)

    click_button "Add Poll"
    find("input[name*='[polls_attributes]'][name$='[question]']").set("What should we eat?")

    click_button "Add an option"
    find("input[name*='[responses_attributes]'][name$='[choice]']").set("Pizza")

    click_button "Update Event"

    expect(page).to have_current_path(event_path(event), ignore_query: true)

    poll = event.reload.polls.includes(:responses).first
    expect(poll.question).to eq "What should we eat?"
    expect(poll.responses.map(&:choice)).to eq ["Pizza"]
    expect(poll.responses.first.example_response).to be true
  end
end
