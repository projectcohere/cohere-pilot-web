module Events
  class DispatchAll < ::Command
    include Service::Single

    # -- lifetime --
    def initialize(
      events: Service::Container.domain_events,
      dispatchers: [Events::DispatchEffects.get, Events::DispatchAnalytics.get]
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
