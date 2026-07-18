# frozen_string_literal: true

require "rails_helper"

RSpec.describe "events rake tasks" do
  include ActiveJob::TestHelper

  before(:all) do
    Rails.application.load_tasks
  end

  def invoke_task(name)
    task = Rake::Task[name]
    task.reenable
    task.invoke
  end

  def attach_photo!(event)
    event.photo.attach(
      io: file_fixture("test_image.png").open,
      filename: "test_image.png",
      content_type: "image/png"
    )
  end

  describe "events:prewarm_header_images" do
    it "queues transform jobs for events missing a stored variant" do
      event = FactoryBot.create(:event)
      attach_photo!(event)
      clear_enqueued_jobs

      expect {
        invoke_task("events:prewarm_header_images")
      }.to output(/Queued 1 header image transform job\(s\); skipped 0/).to_stdout

      expect(ActiveStorage::TransformJob).to have_been_enqueued.with(
        event.photo.blob,
        event.landing_page_photo_transformations
      )
    end

    it "skips events that already have the variant" do
      event = FactoryBot.create(:event)
      attach_photo!(event)
      event.photo.blob.variant_records.create!(
        variation_digest: event.landing_page_photo.variation.digest
      )
      clear_enqueued_jobs

      expect {
        invoke_task("events:prewarm_header_images")
      }.to output(/Queued 0 header image transform job\(s\); skipped 1/).to_stdout

      expect(ActiveStorage::TransformJob).not_to have_been_enqueued
    end
  end

  describe "events:prewarm_header_images_and_wait" do
    around do |example|
      original_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = ActiveJob::QueueAdapters::AsyncAdapter.new
      example.run
    ensure
      ActiveJob::Base.queue_adapter = original_adapter
    end

    before do
      # Async jobs run on other threads and cannot see records in an open transaction.
      DatabaseCleaner.clean
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.start

      # Avoid real image work; LambdaTransform prepends #perform so stub the variant path instead.
      representation = instance_double(ActiveStorage::VariantWithRecord, processed: true)
      allow_any_instance_of(ActiveStorage::Blob).to receive(:representation).and_return(representation)
    end

    it "queues transforms and waits for the async pool to drain" do
      event = FactoryBot.create(:event)
      attach_photo!(event)

      expect {
        invoke_task("events:prewarm_header_images_and_wait")
      }.to output(
        /Queued 1 header image transform job\(s\); skipped 0.*Finished waiting for header image transform job\(s\)\./m
      ).to_stdout
    end

    it "aborts when the queue adapter is not async" do
      ActiveJob::Base.queue_adapter = :test

      expect {
        expect {
          invoke_task("events:prewarm_header_images_and_wait")
        }.to raise_error(SystemExit)
      }.to output(/requires the :async Active Job adapter/).to_stderr
    end
  end
end
