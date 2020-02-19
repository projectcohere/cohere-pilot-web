module Events
  class UploadAnalyticsWorker < ApplicationWorker
    schedule(
      name: "Every 5 minutes",
      cron: "*/5 * * * *"
    )

    # -- command --
    def call
      event_consumer = Mixpanel::Consumer.new

      events = Services.analytics_events
      events.drain do |event|
        event_consumer.send!(*JSON.load(event))
      end
    end

    alias :perform :call
  end
end
