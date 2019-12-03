class ApplicationWorker
  include Sidekiq::Worker

  # -- config --
  def self.schedule(name:, cron:)
    sidekiq_options(retry: false)

    class_name = self.name
    Sidekiq::Cron::Job.create(
      name: "#{class_name} - #{name}",
      cron: cron,
      class: class_name
    )
  end
end
