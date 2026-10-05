require "rails_helper"

RSpec.describe "attendances/attendance" do
  it "shows a gravatar beside the attendee's name" do
    attendance = FactoryBot.build(:attendance, attendee: FactoryBot.build(:user, name: "Maya Chen"))

    render("attendances/attendance", attendance: attendance)

    expect(rendered).to have_css(".attendee-name", text: "Maya Chen")
    expect(rendered).to have_css("img.avatar[src*='secure.gravatar.com/avatar/']")
  end

  it "names the current user as you" do
    attendance = FactoryBot.create(:attendance)

    render("attendances/attendance", attendance: attendance, current_user: attendance.attendee)

    expect(rendered).to have_css(".attendee-name", text: "You")
  end

  it "indents a plus-one under the person who brought them" do
    parent = FactoryBot.create(:guest_attendance, attendee: FactoryBot.create(:guest, name: "Jordan Lee"))
    plus_one = FactoryBot.create(
      :guest_attendance,
      event: parent.event,
      parent_attendance: parent,
      attendee: FactoryBot.create(:guest, name: "Sam")
    )

    render("attendances/attendance", attendance: plus_one)

    expect(rendered).to have_css(".attendee-plus-one", text: "Sam")
    expect(rendered).to have_css(".with-attendee", text: "with Jordan Lee")
  end

  it "shows a remove button to the host" do
    event = FactoryBot.create(:event)
    attendance = FactoryBot.create(:attendance, event: event)

    render("attendances/attendance", attendance: attendance, current_user: event.owner)

    expect(rendered).to have_selector(".remove-attendance")
  end

  it "does not show a remove button to other people" do
    attendance = FactoryBot.create(:attendance)

    render("attendances/attendance", attendance: attendance)

    expect(rendered).not_to have_selector(".remove-attendance")
  end

  it "does not list email addresses" do
    event = FactoryBot.create(:event)
    attendance = FactoryBot.create(:attendance, event: event)

    render("attendances/attendance", attendance: attendance, current_user: event.owner)

    expect(rendered).not_to have_text(attendance.attendee.email)
  end
end
