module Support
  module Tracking
    # -- constants --
    Queue = ArrayQueue.new

    # -- lifecycle --
    Services.resets do
      # fake the tracking events queue
      Services.analytics_events = Queue
    end

    def before_setup
      super
      Services.reset
    end

    def after_teardown
      Queue.clear
      super
    end

    # -- queries --
    def analytics_events
      Queue
    end

    # -- asserts --
    def assert_analytics_events(length, &block)
      assert_equal(analytics_events.length, length)

      if block_given?
        block.(analytics_events)
      end
    end
  end
end

ActiveSupport::TestCase.include(Support::Tracking)
