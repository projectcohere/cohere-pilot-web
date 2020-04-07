module Enroller
  class PublishQueuedCase < ApplicationWorker
    # -- lifetime --
    def initialize(partner_repo: Partner::Repo.get)
      @partner_repo = partner_repo
    end

    # -- command --
    def call(case_id)
      enroller = @partner_repo.find_default_enroller

      Cases::ActivityChannel.broadcast_to(
        enroller.id,
        Cases::ActivityEvent.did_add_queued_case(
          case_id,
        ),
      )
    end
  end
end
