require "rails_helper"

RSpec.describe "dynamic nested records", type: :system do
  it "creates a poll and option added from the event form" do
    event = FactoryBot.create(:event)
    sign_in event.owner
    visit edit_event_path(event)

    click_button "Add Poll"
    find("input[name*='[polls_attributes]'][name$='[question]']").set("What should we eat?")

    click_button "Add an option"
    find("input[name*='[options_attributes]'][name$='[choice]']").set("Pizza")

    click_button "Update Event"

    expect(page).to have_current_path(event_path(event), ignore_query: true)
    expect(page).to have_content("What should we eat?")

    poll = event.reload.polls.includes(options: :responses).first
    option = poll.options.first
    expect(poll.question).to eq "What should we eat?"
    expect(poll.options.map(&:choice)).to eq ["Pizza"]
    expect(poll.responses).to be_empty
    expect(page).to have_field(type: "radio", with: option.id)

    find("input[type='radio'][value='#{option.id}']").click
    click_button "Answer"

    expect(page).to have_css(".poll-option-count", text: "1")
    expect(poll.responses.reload.map(&:poll_option)).to eq [option]
  end
end
