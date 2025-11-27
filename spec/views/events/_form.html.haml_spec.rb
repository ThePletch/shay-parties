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

  it "asks if the event should be secret" do
    event = FactoryBot.create(:event)

    render(
      'events/form',
      event: event
    )

    expect(rendered).to have_text('Secret event')
  end

  it "asks if the event should require COVID testing" do
    event = FactoryBot.create(:event)

    render(
      'events/form',
      event: event
    )

    expect(rendered).to have_text('Require COVID test')
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
        expect(rendered).to have_css('select#event_address_id')

        expect(rendered).to have_selector('option', text: /#{first_addr.street}/)
        expect(rendered).to have_selector('option', text: /#{first_addr.street2}/)
        expect(rendered).to have_selector('option', text: /#{second_addr.street}/)
        expect(rendered).to have_selector('option', text: /#{second_addr.street2}/)
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

      expect(rendered).to have_select('event[address_attributes][state]', with_options: ['Massachusetts'])
    end
  end
end
