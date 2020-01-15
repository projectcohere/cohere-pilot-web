ENV['RAILS_ENV'] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/pride"
require "config/vcr"
require "sidekiq/testing"
require "support/asserts"
require "support/session"
require "support/controller"
require "support/pdfs"
require "support/mailers"
require "support/channels"
require "support/factories"
require "support/analytics"

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

  parallelize(workers: :number_of_processors)

  # load all fixtures
  fixtures(:all)
end
