module Cohere
  class PublishActivity < ApplicationWorker
    # -- lifetime --
    def initialize(partner_repo: Partner::Repo.get)
      @partner_repo = partner_repo
    end

    # -- command --
    def call(case_id, case_has_new_activity)
      cohere = @partner_repo.find_cohere

      Cases::ActivityChannel.broadcast_to(
        cohere.id,
        Cases::ActivityEvent.has_new_activity(
          case_id,
          case_has_new_activity,
        )
      )
    end
  end
end
