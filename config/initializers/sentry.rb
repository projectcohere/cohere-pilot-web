r_config = Rails.application.config

Raven.configure do |config|
  config.sanitize_fields = r_config.filter_parameters.map(&:to_s)
end
