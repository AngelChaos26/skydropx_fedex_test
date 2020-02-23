require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# load `.env` variables to `ENV`
Dotenv::Railtie.load

module Telecomm
  class Application < Rails::Application
    # load
    config.autoload_paths << Rails.root.join('lib', 'pbx')
    config.autoload_paths << Rails.root.join('lib', 'payu')
    config.autoload_paths << Rails.root.join('lib', 'freshdesk')
    config.autoload_paths << Rails.root.join('lib','facturacom')
    config.autoload_paths << Rails.root.join('lib', 'zoho')
    config.autoload_paths << Rails.root.join('lib', 'leads_api')
    config.eager_load_paths << Rails.root.join('lib', 'pbx')
    config.eager_load_paths << Rails.root.join('lib', 'payu')
    config.eager_load_paths << Rails.root.join('lib', 'freshdesk')
    config.eager_load_paths << Rails.root.join('lib','facturacom')
    config.eager_load_paths << Rails.root.join('lib', 'zoho')
    config.eager_load_paths << Rails.root.join('lib', 'leads_api')
    # Initialize configuration defaults for originally generated Rails version.

    # Initialize Timezone
    config.time_zone = 'America/Mexico_City'

    config.load_defaults 5.1

    # Rails Cors Setup via `rack-cors`
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*',
          headers: :any,
          expose: %i[client token-type access-token uid Authorization
                     Beta-Access-Key Beta-Code].freeze,
          methods: %i[get post put delete].freeze
      end
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # 02/27: Explicit `api_only` disable due to OmniAuth + SessionStore
    # compatibilty
    # https://stackoverflow.com/questions/40112749/rails-5-api-omniauth-use-activerecord-session-store
    config.api_only = false
    config.generators do |g|
      # test generators
      g.assets false
      g.test_framework :rspec, fixture: false
      g.controller_specs false
      # unconfigurable
      # g.request_specs true
      g.view_specs false
      g.helper_specs false
    end
    # i18n config
    config.i18n.default_locale = :es
  end
end
