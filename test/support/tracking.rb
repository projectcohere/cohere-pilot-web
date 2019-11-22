module Support
  module Tracking
    # -- constants --
    Queue = EventQueue.new

    # -- lifecycle --
    Services.resets do
      # fake the tracking events queue
      Services.tracking_events = Queue
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
    def tracking_events
      Queue
    end

    # -- asserts --
    def assert_tracking_events(length)
      assert_equal(tracking_events.length, length)
    end
  end
end

ActiveSupport::TestCase.include(Support::Tracking)
