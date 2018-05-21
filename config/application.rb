require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Automata
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # React
    config.react.addons = true

    config.react.server_renderer_options = {
      files: ['AutomataServer.js'] # files to load for prerendering
    }

    # Use for profiling
    # config.middleware.use(StackProf::Middleware, enabled:true, mode: :wall, interval: 1000, save_every: 5)
  end
end
