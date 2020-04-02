require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "test/cassettes"
  c.hook_into(:webmock)
  c.default_cassette_options = {
    allow_unused_http_interactions: false
  }

  c.filter_sensitive_data("<TWILIO_API_ACCOUNT_SID>") { ENV["TWILIO_API_ACCOUNT_SID"] }
  c.filter_sensitive_data("<TWILIO_API_AUTH_TOKEN>") { ENV["TWILIO_API_AUTH_TOKEN"] }
  c.filter_sensitive_data('<TWILIO_API_BASIC_AUTH>') { Base64.strict_encode64("#{ENV.fetch("TWILIO_API_ACCOUNT_SID")}:#{ENV.fetch("TWILIO_API_AUTH_TOKEN")}") }
end
