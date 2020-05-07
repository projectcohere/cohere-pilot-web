module Events
  class DispatchAll < ::Command
    include Service::Single

    # -- props --
    attr(:events)

    # -- lifetime --
    def initialize(
      events: ListQueue.new,
      dispatch_effects: Events::DispatchEffects.get,
      dispatch_analytics: Events::DispatchAnalytics.get
    )
      @events = events
      @dispatch_effects = dispatch_effects
      @dispatch_analytics = dispatch_analytics
    end

    # -- command --
    def call
      # if events are already being dispatched, we don't want to do accidentally execute
      # duplicate work (this really only happens in tests when workers run inline)
      if @dispatching
        return
      end

      @dispatching = true

      # process all the events
      @events.drain do |event|
        @dispatch_effects.(event)
        @dispatch_analytics.(event)
      end

      # commit analytics records
      analytics = @dispatch_analytics.drain
      if analytics.length != 0
        Events::Record.insert_all(analytics.map { |d| { data: d, created_at: Time.now } })
      end

      @dispatching = false
    end
  end
end
