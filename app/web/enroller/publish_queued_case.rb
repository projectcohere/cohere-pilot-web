module Enroller
  class PublishQueuedCase < ApplicationWorker
    # -- command --
    def call(case_id)
      enroller = Partner::Repo.get.find_default_enroller

      Cases::ActivityChannel.broadcast_to(
        enroller.id,
        Cases::ActivityEvent.did_add_queued_case(
          case_id,
        ),
      )
    end
  end
end
