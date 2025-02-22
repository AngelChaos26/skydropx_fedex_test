# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if
  Rails.env.production?
# Add additional requires below this line. Rails is not loaded until this point!
require 'rspec/rails'
require 'database_cleaner'
require 'webmock/rspec'
require 'action_cable/testing/rspec'
# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# include all support classes
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# disable HTTP connections
WebMock.disable_net_connect!

# enable Recaptcha in testing environment
Recaptcha.configuration.skip_verify_env.delete('test')

# VCR config
VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  # Fedex API
  config.register_request_matcher :fedex_api do |real_request, recorded_request|
    url_regex = /^https:\/\/wsbeta\.fedex\.com\/xml.*$/
    real_request.uri == recorded_request.uri ||
      (
        url_regex.match(real_request.uri) &&
        url_regex.match(recorded_request.uri)
      )
  end
end

RSpec.configure do |config|
  # add Route helpers
  config.include Rails.application.routes.url_helpers
  # include capybara config
  config.include Capybara::DSL
  # include RequestSpecHelper
  config.include RequestSpecHelper
  # include SessionHelper
  config.include SessionHelpers
  # include SessionHelper
  config.include SpecHelper
  # Helpers
  config.include Requests::AuthHelpers::Includables, type: :request
  config.extend Requests::AuthHelpers::Extensions, type: :request
  # start by truncating all the tables but then use the faster transaction
  # strategy the rest of the time.
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end
  # start the transaction strategy as examples are run
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

# configure shoulda matchers to use rspec as the test framework and full matcher
#   libraries for rails
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
