# frozen_string_literal: true

require "capybara/cuprite"

Capybara.default_max_wait_time = 5
Capybara.default_selector = :css
Capybara.server = :puma, {Silent: true}

# Rails' driven_by(:cuprite) re-registers Capybara's :cuprite driver and drops these options.
Capybara.register_driver(:ferrum) do |app|
  options = {
    window_size: [1280, 2000],
    js_errors: true,
    headless: ENV["CHROME_HEADLESS"] != "0",
    browser_options: {
      "no-sandbox": nil,
      "disable-dev-shm-usage": nil,
    },
  }
  browser_path = ENV["BROWSER_PATH"].presence || ENV["CHROME_PATH"].presence
  options[:browser_path] = browser_path if browser_path

  Capybara::Cuprite::Driver.new(app, **options)
end

Capybara.javascript_driver = :ferrum

RSpec.configure do |config|
  config.prepend_before(:each, type: :system) do
    driven_by :ferrum
  end
end
