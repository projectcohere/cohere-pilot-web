ENV['RAILS_ENV'] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "support/fixtures"
require "support/sessions"
require "support/asserts"

# load pry-rescue if the flag is set
if ENV["PRY_RESCUE"]
  require "pry-rescue/minitest"
end

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

  # setup fixtures
  # TODO: generalize this for feature-namespaced records?
  set_fixture_class(
    cases: Case::Record,
    recipients: Recipient::Record
  )

  fixtures :all
end
