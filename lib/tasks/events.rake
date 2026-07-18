# frozen_string_literal: true

namespace :events do
  desc "Queue image transform jobs for event header photos missing a stored variant"
  task prewarm_header_images: :environment do
    queued, skipped = queue_missing_header_image_transforms
    puts "Queued #{queued} header image transform job(s); skipped #{skipped} event(s) with existing variants."
  end

  desc "Queue header image transform jobs and wait until they complete or exhaust retries"
  task prewarm_header_images_and_wait: :environment do
    adapter = ActiveJob::Base.queue_adapter
    was_immediate = nil

    unless adapter.is_a?(ActiveJob::QueueAdapters::AsyncAdapter)
      abort "events:prewarm_header_images_and_wait requires the :async Active Job adapter " \
            "(got #{adapter.class.name})."
    end

    # Retry delays would otherwise schedule work outside the thread pool, so the
    # process could exit while retries are still pending. Immediate mode keeps
    # retries on the pool until attempts are exhausted.
    was_immediate = adapter.immediate
    adapter.immediate = true

    queued, skipped = queue_missing_header_image_transforms
    puts "Queued #{queued} header image transform job(s); skipped #{skipped} event(s) with existing variants."

    drain_async_active_jobs!(adapter)
    puts "Finished waiting for header image transform job(s)."
  ensure
    adapter.immediate = was_immediate unless was_immediate.nil?
  end
end

def queue_missing_header_image_transforms
  queued = 0
  skipped = 0

  Event.with_attached_photo.joins(:photo_attachment).find_each do |event|
    if event.landing_page_photo_ready?
      skipped += 1
      next
    end
    event.photo.blob.preprocessed(event.landing_page_photo_transformations)
    queued += 1
  end

  [queued, skipped]
end

def drain_async_active_jobs!(adapter)
  executor = adapter.instance_variable_get(:@scheduler).instance_variable_get(:@async_executor)
  idle_checks = 0

  loop do
    sleep 0.5
    if executor.queue_length.zero? && executor.active_count.zero?
      idle_checks += 1
      break if idle_checks >= 3
    else
      idle_checks = 0
    end
  end
end
