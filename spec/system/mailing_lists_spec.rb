require "rails_helper"

RSpec.describe "mailing lists", type: :system do
  it "renames a list from the list page" do
    user = FactoryBot.create(:user)
    list = FactoryBot.create(:mailing_list, user: user, name: "Friends in town")
    sign_in user

    visit mailing_list_path(list)
    click_button "Actions"
    click_link "Rename"
    fill_in "Name", with: "Friends nearby"
    click_button "Save"

    expect(page).to have_css("h1", text: "Friends nearby")
  end

  it "filters, searches, adds, and removes addresses" do
    user = FactoryBot.create(:user)
    event = FactoryBot.create(:event, owner: user, title: "Rooftop dinner")
    FactoryBot.create(:event, title: "Someone else's party")
    going = FactoryBot.create(:user, name: "Maya Chen", email: "maya@example.com")
    declined = FactoryBot.create(:user, name: "Priya Shah", email: "priya@example.com")
    list = FactoryBot.create(:mailing_list, user: user, name: "Friends in town", emails: [going.email, declined.email, "alex@example.com"])
    list.sync_users
    FactoryBot.create(:attendance, event: event, attendee: going, rsvp_status: "Yes")
    FactoryBot.create(:attendance, event: event, attendee: declined, rsvp_status: "No")
    sign_in user

    visit mailing_lists_path
    expect(page).to have_link("New list")
    expect(page).to have_text("3 addresses")
    expect(page).to have_no_button("Delete list")

    click_link "Friends in town"
    expect(page).to have_text("No account")
    expect(page).to have_no_text("Someone else's party")

    click_link "Going or maybe"
    expect(page).to have_text("maya@example.com")
    expect(page).to have_no_text("priya@example.com")
    expect(page).to have_text("1 of 3 · Going or maybe · Rooftop dinner")
    expect(page).to have_no_css("option", text: "Someone else's party")

    click_link "All"
    fill_in "Search addresses", with: "Priya"
    click_button "Search"
    expect(page).to have_text("priya@example.com")
    expect(page).to have_no_text("maya@example.com")

    visit mailing_list_path(list)
    click_button "Add addresses"
    fill_in "One address per line.", with: "jordan@example.com\nnot-an-email"
    click_button "Add"
    expect(page).to have_text("Added 1 address.")
    expect(page).to have_text("not-an-email")
    expect(page).to have_text("jordan@example.com")

    within("tr", text: "alex@example.com") do
      accept_confirm { click_button "Remove" }
    end
    expect(page).to have_no_css("tr", text: "alex@example.com")
    expect(page).to have_text("Removed alex@example.com.")
  end
end