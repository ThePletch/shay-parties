require "rails_helper"

RSpec.describe "invite recipients", type: :system do
  it "adds a recipient and sends that invite" do
    event = FactoryBot.create(:event)
    sign_in event.owner
    visit new_event_invite_path(event)

    expect(page).to have_css("#invite-recipients [data-controller='dynamic-list-record']", count: 1)

    click_button "Add recipient"
    rows = all("#invite-recipients [data-controller='dynamic-list-record']")
    expect(rows.size).to eq 2

    within(rows.last) do
      find("input[name$='[name]']").set("Ada Lovelace")
      find("input[name$='[email]']").set("ada@example.com")
    end

    within(rows.first) do
      find("[data-dynamic-list-record-target='deleteButton']").click
    end

    expect(page).to have_css("#invite-recipients [data-controller='dynamic-list-record']", count: 1)
    fill_in "Message", with: "Please come!"
    click_button "Send invites"

    expect(page).to have_current_path(event_path(event), ignore_query: true)
    expect(InviteSend.pluck(:recipient_email)).to eq(["ada@example.com"])
  end
end
