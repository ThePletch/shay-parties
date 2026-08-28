ruby '~> 3.4.10'

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 8.0'
gem 'pg', '~> 1.5.3'
gem 'puma', '~> 6.4'
gem 'haml-rails', '~> 2.0'

gem 'draper', '~> 4.0'

gem 'jbuilder', '~> 2.5'

# listings for US states/country metadata
gem 'carmen', '~> 1.1'

# accounts and authentication
gem 'devise', '~> 4.9.4'
# markdown for descriptions
gem 'commonmarker', '~> 2.5'

gem 'aws-sdk-s3', '~> 1.100', require: false
gem 'aws-sdk-lambda', '~> 1.100', require: false

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:windows, :jruby]

gem "icalendar", "~> 2.7"

gem "add_to_calendar", "~> 0.3.0"

gem "friendly_id", "~> 5.4"

gem "bootstrap_form", "~> 5"

# lets us display numbers as locale-specific words
gem "humanize", "~> 3.1"

gem "sorbet-runtime", "~> 0.6.13427"

group :development, :test do
  # Fallback only in dev, production offloads image processing to Lambda
  gem 'image_processing', '~> 1.2'
  gem 'ffi', '~> 1.15.5'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  gem "sorbet", "~> 0.6.13427"
  gem "tapioca", require: false
end

group :development do
  gem 'listen'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'rspec-rails', '~> 6.0'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'capybara', '~> 3.35'
  gem 'poltergeist', '~> 1.18'
  gem 'database_cleaner', '~> 2.0'
end

gem "vite_rails", "~> 3.0"