require "sidekiq/testing"

SidekiqUniqueJobs.configure do |config|
  config.enabled = false
end

module SidekiqPlugin
  def before_setup
    super
    Sidekiq::Testing.inline!
  end
end

ActiveSupport::TestCase.include(SidekiqPlugin)
