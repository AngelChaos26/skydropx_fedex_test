source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# use `active_model_serializers` for JSON serialization
gem 'active_model_serializers', '~> 0.10.6'
# use `dotenv-rails` for ENV variable management
gem 'dotenv-rails', '~> 2.2.1'
# use `kaminari` for ActiveRecord::Relation paging
gem 'kaminari', '~> 1.0.1'
# use `rack-cors` for HTTP cors support
gem 'rack-cors', '~> 1.0.1'
# use `whenever` for background task execution
gem 'whenever', '~> 0.10.0', require: false
# use `rails-settings-cached` for user preferences
gem 'rails-settings-cached', '~> 0.6.6'
# Use `activerecord-session_store` for session storage
gem 'activerecord-session_store', '~> 1.1.0'
# Use Act as List for priority field mapping
gem 'acts_as_list', '~> 0.9.10'
# use grecaptcha for bot request prevention
gem 'recaptcha', '~> 4.3.1', require: 'recaptcha/rails'
# 0512: use pry since freshsales gem requires this gem and is not stated as
#   dependency
gem 'pry', '~> 0.11.2'
# unicorn for dockers
gem 'unicorn', '~>5.4.0'
# use fedex for tracking and deliver packages, in this case for testing
gem 'fedex', '~>3.10.11'

group :test do
  gem 'rspec-rails', '~> 3.7.1'
  # use shoulda-matchers to enforce unit test within models
  gem 'shoulda-matchers', '~> 3.1'
  # use database_cleaner to truncate the contents of the database in every
  #   example run
  gem 'database_cleaner', '~> 1.6.2'
  # enable mocks within context examples
  gem 'webmock', '~> 3.1.0'
  # use `timecop` for "time travel" and "time freezing" capabilities
  gem 'timecop', '~> 0.8.1'
  # use VCR for remote API interactions
  gem 'vcr', '~> 3.0.3'
  # authorization policy testing
  gem 'pundit-matchers', '~> 1.6.0'
end

group :development, :test, :stage do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  # ruby code style fixing
  gem 'rubocop-rails', '~> 2.4.1', require: false
  # debugging
  gem 'pry-rails', '~> 0.3.6'
  # use pry stack for debug stack info
  gem 'pry-stack_explorer', '~> 0.4.9.2'
  # action cable testing
  gem 'action-cable-testing', '~> 0.6.0'
end

group :development, :stage do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano', '= 3.10.0'
  gem 'capistrano-env-config', '~> 0.3.0'
  gem 'capistrano-rails', '~> 1.3'
  gem 'capistrano-rvm',   '~> 0.1'
  gem 'capistrano-passenger', '~> 0.2.0'
  gem 'capistrano-sidekiq', '~> 1.0.0'
end

group :production do
  gem 'sidekiq', '~> 4.0.2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
