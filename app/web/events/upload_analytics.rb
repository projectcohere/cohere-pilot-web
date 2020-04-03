module Events
  class UploadAnalytics < ApplicationWorker
    schedule(
      name: "Every 5 minutes",
      cron: "*/5 * * * *"
    )

    # -- lifetime --
    def initialize(analytics_events: Service::Container.analytics_events)
      @analytics_events = analytics_events
    end

    # -- command --
    def call
      event_consumer = Mixpanel::Consumer.new

      @analytics_events.drain do |event|
        event_consumer.send!(*JSON.load(event))
      end
    end
  end
end
