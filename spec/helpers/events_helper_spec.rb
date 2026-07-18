# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventsHelper, type: :helper do
  describe "#event_header_image_tag" do
    let(:event) { FactoryBot.create(:event) }

    it "renders the default image when no photo is attached" do
      html = helper.event_header_image_tag(event)

      expect(html).to include(helper.vite_asset_path("images/default_event_image.jpg"))
      expect(html).to include('class="hero-photo"')
    end

    it "renders a CSS-cropped original while the variant is processing" do
      event.photo.attach(
        io: file_fixture("test_image.png").open,
        filename: "test_image.png",
        content_type: "image/png"
      )
      event.update!(photo_crop_y_offset: 25)

      html = helper.event_header_image_tag(event)

      expect(html).to include("hero-photo--pending")
      expect(html).to include('data-crop-y-offset="25"')
    end

    it "renders the processed variant when it is ready" do
      event.photo.attach(
        io: file_fixture("test_image.png").open,
        filename: "test_image.png",
        content_type: "image/png"
      )
      event.photo.blob.variant_records.create!(
        variation_digest: event.landing_page_photo.variation.digest
      ).tap do |record|
        record.image.attach(
          io: file_fixture("test_image.png").open,
          filename: "test_image.png",
          content_type: "image/png"
        )
      end

      html = helper.event_header_image_tag(event)

      expect(html).not_to include("hero-photo--pending")
      expect(html).to include("/rails/active_storage/representations/redirect/")
    end
  end
end
