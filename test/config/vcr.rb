require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "test/cassettes"
  c.hook_into(:webmock)
  c.filter_sensitive_data("<FRONT_API_JWT>") { ENV["FRONT_API_JWT"] }
end
