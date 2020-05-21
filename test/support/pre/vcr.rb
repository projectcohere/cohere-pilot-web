require "vcr"

VCR.configure do |c|
  c.hook_into(:webmock)
  c.cassette_library_dir = "test/cassettes"
  c.default_cassette_options = {
    allow_unused_http_interactions: false
  }

  # -- ignores --
  # ignore selenium paths
  ignore_paths = %w[session shutdown __identify__]
  ignore_paths = /\/(#{ignore_paths.join("|")})/

  c.ignore_request do |request|
    uri = URI(request.uri)
    uri.host == "127.0.0.1" && ignore_paths.match?(uri.path)
  end

  # -- filters --
  c.filter_sensitive_data("<TWILIO_API_ACCOUNT_SID>") { ENV["TWILIO_API_ACCOUNT_SID"] }
  c.filter_sensitive_data("<TWILIO_API_AUTH_TOKEN>") { ENV["TWILIO_API_AUTH_TOKEN"] }
  c.filter_sensitive_data('<TWILIO_API_BASIC_AUTH>') { Base64.strict_encode64("#{ENV.fetch("TWILIO_API_ACCOUNT_SID")}:#{ENV.fetch("TWILIO_API_AUTH_TOKEN")}") }
end
