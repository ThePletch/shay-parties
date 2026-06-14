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

    expect do
      event.update!(photo_crop_y_offset: 40)
    end.to have_enqueued_job(ActiveStorage::TransformJob).with(
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
end
