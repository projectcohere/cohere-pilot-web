require_relative "shared/fixtures"
require "sidekiq/cron"

Rails.application.configure do
  should_cache = Rails.root.join('tmp', 'caching-dev.txt').exist?

  # -- root --
  config.eager_load = false
  config.consider_all_requests_local = true
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # -- root/cache
  config.cache_classes = false
  config.cache_store = :null_store

  if should_cache
    config.cache_store = :memory_store
  end

  # -- assets --
  config.assets.debug = true
  config.assets.quiet = true

  # -- public file server --
  if should_cache
    headers = { "Cache-Control" => "public, max-age=#{2.days.to_i}" }
    config.public_file_server.headers = headers
  end

  # -- action controller --
  config.action_controller.perform_caching = false

  if should_cache
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
  end

  # -- active storage --
  config.active_storage.service = :local

  # -- action mailer --
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # -- active support --
  config.active_support.deprecation = :log

  # -- active record --
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
end
