Rails.application.configure do
  # -- root --
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.force_ssl = true

  # -- root/logging
  config.log_level = :debug
  config.log_tags = [ :request_id ]
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # -- assets --
  config.assets.compile = false

  # -- i18n --
  config.i18n.fallbacks = true

  # -- public file server --
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # -- action controller --
  config.action_controller.perform_caching = true

  # -- active storage --
  config.active_storage.service = :amazon

  # -- action mailer --
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    user_name: ENV["SMTP_USERNAME"],
    password: ENV["SMTP_PASSWORD"],
    address: ENV["SMTP_ADDRESS"],
    domain: ENV["SMTP_DOMAIN"],
    port: ENV["SMTP_PORT"],
    authentication: ENV["SMTP_AUTHENTICATION"].to_sym,
    enable_starttls_auto: ENV["SMTP_STARTTLS"].present?
  }

  # -- active support --
  config.active_support.deprecation = :notify

  # -- active record --
  config.active_record.dump_schema_after_migration = false
end
