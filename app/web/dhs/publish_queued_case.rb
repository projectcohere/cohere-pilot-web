module Dhs
  class PublishQueuedCase < ApplicationWorker
    # -- command --
    def call(case_id)
      dhs = Partner::Repo.get.find_dhs

      Cases::ActivityChannel.broadcast_to(
        dhs.id,
        Cases::ActivityEvent.did_add_queued_case(
          case_id,
        ),
      )
    end
  end
end
