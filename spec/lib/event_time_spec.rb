require "rails_helper"

RSpec.describe EventTime do
  it "joins start and end clocks for a same-day event" do
    event = FactoryBot.build(
      :event,
      start_time: Time.zone.parse("2026-08-28 10:00"),
      end_time: Time.zone.parse("2026-08-28 22:00")
    )

    expect(EventTime.same_day_range(event)).to eq(
      "#{I18n.l(event.start_time, format: :clock)} - #{I18n.l(event.end_time, format: :clock)}"
    )
  end
end
