module Cohere
  class PublishActivity < ApplicationWorker
    # -- command --
    def call(case_id, case_has_new_activity)
      cohere = Partner::Repo.get.find_cohere

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
