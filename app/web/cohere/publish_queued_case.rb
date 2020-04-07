module Cohere
  class PublishQueuedCase < ApplicationWorker
    # -- lifetime --
    def initialize(partner_repo: Partner::Repo.get)
      @partner_repo = partner_repo
    end

    # -- command --
    def call(case_id)
      cohere = @partner_repo.find_cohere

      Cases::ActivityChannel.broadcast_to(
        cohere.id,
        Cases::ActivityEvent.did_add_queued_case(
          case_id,
        ),
      )
    end
  end
end
