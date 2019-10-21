require_relative 'boot'
require 'rails/all'

# require the gems listed in Gemfile, including any gems
Bundler.require(*Rails.groups)

module CoherePilotWeb
  class Application < Rails::Application
    config.load_defaults(6.0)

    # assets
    config.assets.enabled = true
    config.assets.paths << "#{Rails.root}/app/assets/fonts"

    # autoload
    config.autoload_paths += %w[
      app/features/base
      app/web/base
      app/web/concerns
    ]
  end
end
