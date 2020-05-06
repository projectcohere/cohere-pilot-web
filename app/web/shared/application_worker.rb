class ApplicationWorker
  include Sidekiq::Worker

  # -- Sidekiq::Worker
  def perform(*args)
    # run the job
    call(*args)

    # dispatch any queued events
    Events::DispatchAll.()
  end
end
