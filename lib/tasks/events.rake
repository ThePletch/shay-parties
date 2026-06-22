# frozen_string_literal: true

namespace :events do
  desc "Queue image transform jobs for event header photos missing a stored variant"
  task prewarm_header_images: :environment do
    queued = 0
    skipped = 0

    Event.with_attached_photo.find_each do |event|
      if event.landing_page_photo_ready?
        skipped += 1
        next
      end

      event.photo.blob.preprocessed(event.landing_page_photo_transformations)
      queued += 1
    end

    puts "Queued #{queued} header image transform job(s); skipped #{skipped} event(s) with existing variants."
  end
end
