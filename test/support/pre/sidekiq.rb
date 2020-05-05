require "sidekiq/testing"

module SidekiqPlugin
  def before_setup
    super
    Sidekiq::Testing.inline!
  end
end

ActiveSupport::TestCase.include(SidekiqPlugin)
