require "rails_helper"

RSpec.describe "event show", type: :system do
  it "shows the COVID test rule smaller than the rest of the page" do
    event = FactoryBot.create(:event, requires_testing: true)
    visit event_path(event)

    sizes = page.evaluate_script(<<~JS)
      (() => {
        const detail = getComputedStyle(document.querySelector(".testing-requirement small"));
        const body = getComputedStyle(document.body);
        return { detail: parseFloat(detail.fontSize), body: parseFloat(body.fontSize) };
      })()
    JS

    expect(page).to have_css("small", text: "negative rapid COVID test")
    expect(sizes["detail"]).to be < sizes["body"]
  end

  it "shows saved plus-ones as names and emails until they are edited" do
    event = FactoryBot.create(:event)
    attendance = FactoryBot.create(:attendance, event: event, attendee: event.owner, rsvp_status: "Yes")
    FactoryBot.create(
      :guest_attendance,
      event: event,
      parent_attendance: attendance,
      attendee: FactoryBot.create(:guest, name: "Sam", email: "sam@example.com")
    )
    sign_in event.owner
    visit event_path(event)

    within(".rsvp-plus-ones") do
      expect(page).to have_text("Plus-ones")
      expect(page).to have_text("+1 · Sam · sam@example.com")
      expect(page).to have_no_field("Name")
      click_button "Edit +1s"
      expect(page).to have_field("Name", with: "Sam")
      expect(page).to have_field("Email", with: "sam@example.com")
      expect(page).to have_button("Bring someone")
      expect(page).to have_button("Remove")
      expect(page).to have_button("Update")
      expect(page).to have_button("Cancel")
    end
  end

  it "keeps an existing plus-one editable after the event stops allowing them" do
    event = FactoryBot.create(:event)
    attendance = FactoryBot.create(:attendance, event: event, attendee: event.owner, rsvp_status: "Yes")
    FactoryBot.create(
      :guest_attendance,
      event: event,
      parent_attendance: attendance,
      attendee: FactoryBot.create(:guest, name: "Sam", email: "sam@example.com")
    )
    event.update!(plus_one_max: 0)
    sign_in event.owner
    visit event_path(event)

    within(".rsvp-plus-ones") do
      expect(page).to have_text("Plus-ones")
      expect(page).to have_text("+1 · Sam · sam@example.com")
      expect(page).to have_no_button("Bring someone")
      click_button "Edit +1s"
      expect(page).to have_field("Name", with: "Sam")
      expect(page).to have_field("Email", with: "sam@example.com")
    end

    find("label.btn", text: "Maybe").click

    expect(page).to have_text("RSVP updated.")
    expect(attendance.reload.rsvp_status).to eq "Maybe"
  end

  it "adds a plus-one with the same name and email fields as a guest RSVP" do
    event = FactoryBot.create(:event)
    sign_in event.owner
    visit event_path(event)
    find("label.btn", text: "Going").click

    expect(page).to have_button("Bring someone")
    click_button "Bring someone"

    within(".rsvp-plus-one") do
      expect(page).to have_field("Name")
      expect(page).to have_field("Email")
      expect(page).to have_button("Remove")
      expect(page).to have_no_css(".input-group")
    end
    expect(page).to have_button("Update")
    expect(page).to have_button("Cancel")
  end

  it "keeps update available after removing a plus-one and cancels back to the summary" do
    event = FactoryBot.create(:event, plus_one_max: 1)
    attendance = FactoryBot.create(:attendance, event: event, attendee: event.owner, rsvp_status: "Yes")
    plus_one = FactoryBot.create(
      :guest_attendance,
      event: event,
      parent_attendance: attendance,
      attendee: FactoryBot.create(:guest, name: "Sam", email: "sam@example.com")
    )
    sign_in event.owner
    visit event_path(event)

    within(".rsvp-plus-ones") do
      click_button "Edit +1s"
      expect(page).to have_no_button("Bring someone")
      click_button "Remove"
      expect(page).to have_button("Update")
      expect(page).to have_button("Bring someone")
      click_button "Cancel"
      expect(page).to have_text("+1 · Sam · sam@example.com")
      expect(page).to have_no_field("Name")
      expect(page).to have_no_button("Update")
    end

    expect(Attendance.find_by(id: plus_one.id)).to be_present
  end

  it "asks a guest for a name and email only after they choose a response" do
    event = FactoryBot.create(:event, title: "Rooftop potluck")
    visit event_path(event)

    expect(page).to have_css("h1", text: "Rooftop potluck")
    expect(page).to have_no_field("Name")

    find("label.btn", text: "Going").click
    fill_in "Name", with: "Maya Chen"
    fill_in "Email", with: "maya@example.com"
    click_button "RSVP going"

    expect(page).to have_text("Maya Chen · maya@example.com")
    expect(page).to have_css(".attendee-name", text: "Maya Chen")
    expect(page).to have_no_button("RSVP going")

    metrics = page.evaluate_script(<<~JS)
      (() => {
        const column = document.querySelector(".event-show");
        const box = column.getBoundingClientRect();
        const hero = document.querySelector(".hero-photo").getBoundingClientRect();
        return {
          columnWidth: box.width,
          maxWidth: parseFloat(getComputedStyle(column).maxWidth),
          heroWidth: hero.width,
          leftGap: box.left,
          rightGap: hero.right - box.right,
        };
      })()
    JS
    expect(metrics["maxWidth"]).to eq(metrics["columnWidth"])
    expect(metrics["heroWidth"]).to be > metrics["columnWidth"]
    expect(metrics["leftGap"]).to be_within(2).of(metrics["rightGap"])
  end

  it "keeps host tools in Manage and records the host's choice without an identity form" do
    event = FactoryBot.create(:event)
    sign_in event.owner
    visit event_path(event)

    expect(page).to have_no_field("Name")
    expect(page).to have_no_link("Edit event")

    find("summary", text: "Manage").click
    expect(page).to have_link("Edit event", href: edit_event_path(event))
    expect(page).to have_link("Send invites")
    expect(page).to have_css("summary", text: "Copy guest emails")

    find("label.btn", text: "Maybe").click
    expect(page).to have_css(".going-count", text: "0 going")
    expect(page).to have_css(".other-rsvps", text: "1 maybe · 0 can’t come")
    find(".other-rsvps summary").click
    expect(page).to have_css(".attendee-name", text: "You")
  end

  it "asks before a host removes an attendee" do
    event = FactoryBot.create(:event)
    attendance = FactoryBot.create(:guest_attendance, event: event, attendee: FactoryBot.create(:guest, name: "Sam"))
    sign_in event.owner
    visit event_path(event)

    within(".attendee-row", text: "Sam") do
      dismiss_confirm { click_button "Remove" }
    end
    expect(Attendance.find_by(id: attendance.id)).to be_present

    within(".attendee-row", text: "Sam") do
      accept_confirm { click_button "Remove" }
    end
    expect(page).to have_no_css(".attendee-name", text: "Sam")
    expect(Attendance.find_by(id: attendance.id)).to be_nil
  end
end