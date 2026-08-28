require 'rails_helper'

RSpec.describe Event do
  include ActiveJob::TestHelper

  it "lets you save a valid event" do
    huge_party = Event.new(
      start_time: DateTime.iso8601('2019-05-01T17:00:00+05:00'),
      end_time: DateTime.iso8601('2019-05-01T17:02:00+05:00')
    )
    expect(huge_party).to be_valid
  end

  it "rejects events that start after they end" do
    time_travel_convention = Event.new(start_time: Time.current, end_time: Time.current - 1)
    expect(time_travel_convention).not_to be_valid
    expect(time_travel_convention.errors.messages.keys).to include :end_time
  end

  it "prewarms the landing page photo when the crop offset changes" do
    event = FactoryBot.create(:event)
    event.photo.attach(
      io: file_fixture("test_image.png").open,
      filename: "test_image.png",
      content_type: "image/png"
    )

    event.update!(photo_crop_y_offset: 40)

    expect(ActiveStorage::TransformJob).to have_been_enqueued.with(
      event.photo.blob,
      event.landing_page_photo_transformations
    )
  end

  it "reports when the landing page photo variant is ready" do
    event = FactoryBot.create(:event)
    event.photo.attach(
      io: file_fixture("test_image.png").open,
      filename: "test_image.png",
      content_type: "image/png"
    )

    expect(event.landing_page_photo_ready?).to be(false)

    event.photo.blob.variant_records.create!(
      variation_digest: event.landing_page_photo.variation.digest
    )

    expect(event.landing_page_photo_ready?).to be(true)
  end

  describe "#attended_by?" do
    it "is true when the attendee RSVPed yes or maybe" do
      attendance = FactoryBot.create(:attendance, rsvp_status: "Yes")

      expect(attendance.event.attended_by?(attendance.attendee)).to be(true)
    end

    it "is false when the attendee RSVPed no" do
      attendance = FactoryBot.create(:attendance, rsvp_status: "No")

      expect(attendance.event.attended_by?(attendance.attendee)).to be(false)
    end

    it "is false when there is no attendee" do
      event = FactoryBot.create(:event)

      expect(event.attended_by?(nil)).to be(false)
    end
  end

  describe "#single_day?" do
    it "is true when start and end fall on the same calendar day" do
      event = FactoryBot.build(
        :event,
        start_time: Time.zone.parse("2026-08-28 10:00"),
        end_time: Time.zone.parse("2026-08-28 22:00")
      )

      expect(event).to be_single_day
    end

    it "is false when the event spans midnight" do
      event = FactoryBot.build(
        :event,
        start_time: Time.zone.parse("2026-08-28 22:00"),
        end_time: Time.zone.parse("2026-08-29 01:00")
      )

      expect(event).not_to be_single_day
    end
  end

  describe "#root_comments" do
    it "returns comments with no parent" do
      event = FactoryBot.create(:event)
      root = FactoryBot.create(:comment, event: event)
      FactoryBot.create(:comment, event: event, parent: root)

      expect(event.root_comments).to eq([root])
    end
  end
end
