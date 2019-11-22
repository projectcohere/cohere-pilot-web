module Events
  class UploadAnalyticsWorker < ApplicationWorker
    sidekiq_options(retry: false)

    # -- command --
    def perform
      event_consumer = Mixpanel::Consumer.new

      events = Services.analytics_events
      events.drain do |event|
        event_consumer.send!(*JSON.load(event))
      end
    end
  end
end

Sidekiq::Cron::Job.create(
  name: "Events::UploadAnalyticsWorker - Every  5 Minutes",
  cron: "*/5 * * * *",
  class: "Events::UploadAnalyticsWorker"
)
