module Events
  class DispatchAll < ::Command
    include Service::Singleton

    # -- lifetime --
    def initialize(
      events: Service::Container.domain_events,
      dispatchers: [DispatchEffects.get, DispatchAnalytics.get]
    )
      @events = events
      @dispatchers = dispatchers
    end

    # -- command --
    def call
      # if events are already being dispatched, we don't want to do accidentally execute
      # duplicate work (this really only happens in tests when workers run inline)
      if @dispatching
        return
      end

      @dispatching = true

      @events.drain do |event|
        @dispatchers.each do |dispatch|
          dispatch.(event)
        end
      end

      @dispatching = false
    end
  end
end
