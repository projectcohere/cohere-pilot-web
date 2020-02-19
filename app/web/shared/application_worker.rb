class ApplicationWorker
  include Sidekiq::Worker

  # -- config --
  def self.schedule(name:, cron:)
    if Rails.env.test?
      return
    end

    sidekiq_options(retry: false)

    class_name = self.name
    Sidekiq::Cron::Job.create(
      name: "#{class_name} - #{name}",
      cron: cron,
      class: class_name
    )
  end
end
