require_relative "shared/fixtures"

Rails.application.configure do
  should_cache = Rails.root.join('tmp', 'caching-dev.txt').exist?

  # -- root --
  config.hosts << /[a-z0-9]+\.ngrok\.io/
  config.eager_load = false
  config.consider_all_requests_local = true
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # -- root/cache
  config.cache_classes = false
  config.cache_store = :null_store

  if should_cache
    config.cache_store = :memory_store
  end

  # -- root/logging --
  config.log_level = ENV["LOG_LEVEL"]&.to_sym || :debug

  s = Sidekiq
  s.logger.level = Logger::FATAL
  s.configure_server do |c|
    c.logger.level = config.log_level
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
