# frozen_string_literal: true

require "rake"

module RakeExampleGroup
  # Rails.application.load_tasks is not idempotent: it re-loads every
  # lib/tasks/*.rake file and appends another action to existing tasks.
  def self.load_tasks_once
    return if @tasks_loaded

    @tasks_loaded = true
    Rails.application.load_tasks
  end

  def invoke_task(name, *args)
    Rake::Task[name].tap(&:reenable).invoke(*args)
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/lib/tasks/}) do |metadata|
    metadata[:type] ||= :rake
  end

  config.include RakeExampleGroup, type: :rake
  config.before(:each, type: :rake) { RakeExampleGroup.load_tasks_once }
end
