ENV['RAILS_ENV'] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "minitest/pride"
require_many("support/pre/*.rb", scope: "test")
require_many("support/*.rb", scope: "test")

# load pry-rescue if the flag is set
if ENV["PRY_RESCUE"]
  require "pry-rescue/minitest"
end

class ActiveSupport::TestCase
  # parallelize tests
  parallelize_setup do |worker|
    # copy activestorage tmp files into
    FileUtils.cp_r("./test/fixtures/files/storage", "./tmp")
  end

  parallelize(workers: ENV["PRY_RESCUE"] ? 1 : :number_of_processors)

  # load all fixtures
  fixtures(:all)
end
