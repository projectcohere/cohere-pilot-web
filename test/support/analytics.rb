module Support
  module Analytics
    # -- asserts --
    def assert_analytics_events(event_names)
      events = Events::Record.all

      assert_equal(
        events.map { |r| r.data["name"] },
        event_names,
      )
    end
  end
end

ActiveSupport::TestCase.include(Support::Analytics)
