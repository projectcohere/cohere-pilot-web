module Cohere
  class PublishQueuedCase < ApplicationWorker
    # -- command --
    def call(case_id)
      cohere = Partner::Repo.get.find_cohere

      Cases::ActivityChannel.broadcast_to(
        cohere.id,
        Cases::ActivityEvent.did_add_queued_case(
          case_id,
        ),
      )
    end

    alias :perform :call
  end
end
