require_relative "shared/fixtures"

Rails.application.configure do
  # -- root --
  config.cache_classes = false
  config.eager_load = false
  config.cache_store = :null_store
  config.consider_all_requests_local = true

  # -- public file server --
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # -- action dispatch --
  config.action_dispatch.show_exceptions = false

  # -- action controller --
  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection = false

  # -- active storage
  config.active_storage.service = :test

  # -- action mailer --
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test

  # -- active support --
  config.active_support.deprecation = :stderr
end
