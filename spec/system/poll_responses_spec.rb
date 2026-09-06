require "rails_helper"

RSpec.describe "poll responses", type: :system do
  it "lets an attendee answer, change, and clear a poll from the event page" do
    event = FactoryBot.create(:event)
    poll = FactoryBot.create(:poll, event: event, question: "What should we eat?")
    pizza = FactoryBot.create(:poll_option, poll: poll, choice: "Pizza")
    tacos = FactoryBot.create(:poll_option, poll: poll, choice: "Tacos")
    sign_in event.owner
    visit event_path(event)

    expect(page).to have_css(".poll-question", text: "What should we eat?")
    expect(page).to have_no_css(".poll-option-count", text: /\d/)

    find("label.poll-option-choice", text: "Pizza").click
    click_button "Answer"

    expect(page).to have_content("Responded to poll.")
    within("label.poll-option-choice", text: "Pizza") do
      expect(page).to have_css(".poll-option-count", text: "1")
      expect(page).to have_checked_field(type: "radio", with: pizza.id)
    end
    expect(poll.responses.reload.map(&:poll_option)).to eq [pizza]

    find("label.poll-option-choice", text: "Tacos").click
    click_button "Update"

    expect(page).to have_content("Poll response updated.")
    within("label.poll-option-choice", text: "Tacos") do
      expect(page).to have_css(".poll-option-count", text: "1")
      expect(page).to have_checked_field(type: "radio", with: tacos.id)
    end
    within("label.poll-option-choice", text: "Pizza") do
      expect(page).to have_no_css(".poll-option-count", text: /\d/)
    end
    expect(poll.responses.reload.map(&:poll_option)).to eq [tacos]

    click_button "Clear"

    expect(page).to have_content("Poll response cleared.")
    expect(page).to have_no_css(".poll-option-count", text: /\d/)
    expect(page).to have_no_checked_field(type: "radio")
    expect(poll.responses.reload).to be_empty
  end
end
