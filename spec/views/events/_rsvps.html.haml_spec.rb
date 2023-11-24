require "rails_helper"

RSpec.describe "events/_rsvps" do
  it "shows the number of attendees per category" do
    event = FactoryBot.create(:event)
    FactoryBot.create_list(
      :attendance,
      2,
      event: event,
      rsvp_status: 'Yes',
    )
    FactoryBot.create_list(
      :attendance,
      1,
      event: event,
      rsvp_status: 'No',
    )

    render('events/rsvps', event: event)

    expect(rendered).to have_selector('#going-tab') do |tab|
      expect(tab).to have_text('2')
    end

    expect(rendered).to have_selector('#maybe-tab') do |tab|
      expect(tab).to have_text('0')
    end

    expect(rendered).to have_selector('#not-going-tab') do |tab|
      expect(tab).to have_text('1')
    end
  end

  it "shows a row for each attendee" do
    event = FactoryBot.create(:event)

    attendee_a = FactoryBot.create(:user, name: 'Argle')
    attendee_b = FactoryBot.create(:user, name: 'Bargle')

    [attendee_a, attendee_b].each do |attendee|
      FactoryBot.create(:attendance, event: event, attendee: attendee)
    end

    render('events/rsvps', event: event)

    expect(rendered).to have_selector('#going') do |section|
      expect(section).to have_text(attendee_a.name)
      expect(section).to have_text(attendee_b.name)
    end
  end
end
