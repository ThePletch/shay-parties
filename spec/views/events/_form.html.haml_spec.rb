require "rails_helper"

RSpec.describe "events/_form" do
  before do
    assign(:prior_addresses, [])
  end

  it "shows error messages if present" do
    event = FactoryBot.build(
      :event,
      start_time: Time.current,
      end_time: Time.current - 1,
    )
    event.valid?

    render(
      'events/form',
      event: event
    )

    expect(rendered).to have_selector('.invalid-feedback')
  end

  it "asks if the event should require COVID testing" do
    event = FactoryBot.create(:event)

    render(
      'events/form',
      event: event
    )

    expect(rendered).to have_text('Require COVID test')
    expect(rendered).to have_css('#event-testing-help', visible: :hidden, text: 'Guests see a note on the event page')
  end

  it "shows the testing note when the event requires a test" do
    event = FactoryBot.create(:event, requires_testing: true)

    render(
      'events/form',
      event: event
    )

    expect(rendered).to have_css('#event-testing-help', visible: :visible, text: 'how to send proof of a test')
  end

  it "uses one control for plus-ones" do
    event = FactoryBot.build(:event, plus_one_max: 2)

    render(
      'events/form',
      event: event
    )

    expect(rendered).to have_select('event[plus_one_max]', selected: '2', with_options: ['None', 'Unlimited'])
    expect(rendered).not_to have_text('Allow +1s?')
    expect(rendered).not_to have_css('#preview')
  end

  it "summarizes a saved location until it is edited" do
    event = FactoryBot.create(:event)

    render(
      'events/form',
      event: event
    )

    expect(rendered).to have_css('#event-location-line', text: event.address.street)
    expect(rendered).to have_css('#event-location-editor', visible: :hidden)
    expect(rendered).to have_field('event[address_attributes][street]', visible: :all)
  end

  it "starts with a closed location editor when the address is blank" do
    render(
      'events/form',
      event: Event.new
    )

    expect(rendered).to have_css('#event-location-add', visible: :visible, text: 'Add a location')
    expect(rendered).to have_css('#event-location-filled', visible: :hidden)
    expect(rendered).to have_css('#event-location-editor', visible: :hidden)
  end

  context "addresses" do
    context "for a new event" do
      it "shows a prompt for prior addresses" do
        first_addr = FactoryBot.create(:address)
        second_addr = FactoryBot.create(:address)
        assign(:prior_addresses, [first_addr, second_addr])

        render(
          "events/form",
          event: Event.new
        )
        expect(rendered).to have_css('select#event_address_id', visible: :all)

        expect(rendered).to have_selector('option', text: /#{first_addr.street}/, visible: :all)
        expect(rendered).to have_selector('option', text: /#{first_addr.street2}/, visible: :all)
        expect(rendered).to have_selector('option', text: /#{second_addr.street}/, visible: :all)
        expect(rendered).to have_selector('option', text: /#{second_addr.street2}/, visible: :all)
      end

      it "does not list prior addresses if none exist" do
        assign(:prior_addresses, [])

        render(
          "events/form",
          event: Event.new
        )

        expect(rendered).not_to have_css('select#event_address_id')
      end
    end

    context "for an existing event" do
      it "does not show a 'prior addresses' dropdown" do
        first_addr = FactoryBot.create(:address)
        second_addr = FactoryBot.create(:address)
        assign(:prior_addresses, [first_addr, second_addr])
        render(
          "events/form",
          event: FactoryBot.create(:event)
        )
        expect(rendered).not_to have_css('select#event_address_id')
      end
    end

    it "lists US states as options" do
      assign(:prior_addresses, [])

      render(
        "events/form",
        event: Event.new
      )

      expect(rendered).to have_select('event[address_attributes][state]', with_options: ['Massachusetts'], visible: :all)
    end
  end
end
