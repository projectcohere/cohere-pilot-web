require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "test/cassettes"
  c.hook_into(:webmock)

  c.filter_sensitive_data("<FRONT_API_JWT>") { ENV["FRONT_API_JWT"] }
  c.filter_sensitive_data("<TWILIO_API_VERIFY_SID>") { ENV["TWILIO_API_VERIFY_SID"] }
  c.filter_sensitive_data("<TWILIO_API_KEY>") { ENV["TWILIO_API_KEY"] }
  c.filter_sensitive_data("<TWILIO_API_SECRET>") { ENV["TWILIO_API_SECRET"] }
  c.filter_sensitive_data('<TWILIO_API_BASIC_AUTH>') { Base64.strict_encode64("#{ENV.fetch("TWILIO_API_KEY")}:#{ENV.fetch("TWILIO_API_SECRET")}") }
end
