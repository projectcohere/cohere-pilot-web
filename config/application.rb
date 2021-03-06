require_relative "boot"
require "rails/all"

# require the gems listed in Gemfile, including any gems
Bundler.require(*Rails.groups)

module CoherePilotWeb
  class Application < Rails::Application
    config.load_defaults(6.0)

    # autoload
    config.eager_load_paths += [
      Rails.root.join("app", "domain", "shared"),
      Rails.root.join("app", "web", "shared"),
    ]
  end
end
