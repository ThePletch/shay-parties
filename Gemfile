ruby '~> 3.1.3'

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.7'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.4.5'
# Use Puma as the app server
gem 'puma', '~> 6.0.0'
# Use SCSS for stylesheets
gem 'sassc', '~> 2.4'
gem 'haml-rails', '~> 2.0.0'

gem 'draper', '~> 4.0'

# use bootstrap as css framework
gem 'bootstrap', '~> 5.1'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.4'
gem 'jquery-ui-rails', '~> 6.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
gem 'ffi', '~> 1.15.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# listings for US states/country metadata
gem 'carmen', '~> 1.1'

# accounts and authentication
gem 'devise', '~> 4.8'
# markdown for descriptions
gem 'commonmarker', '~> 1.0.0.pre3'

gem 'aws-sdk-s3', '~> 1.100', require: false
gem 'image_processing', '~> 1.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rb-readline'
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.1'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'rspec-rails', '~> 5.0'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'factory_bot_rails', '~> 4.8'
  gem 'capybara', '~> 3.35'
  gem 'poltergeist', '~> 1.18'
  gem 'database_cleaner', '~> 2.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "icalendar", "~> 2.7"

gem "add_to_calendar", "~> 0.2.5"

gem "friendly_id", "~> 5.4"

gem "bootstrap_form", "~> 5"
