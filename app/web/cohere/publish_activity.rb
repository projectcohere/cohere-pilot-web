module Cohere
  class PublishActivity < ApplicationWorker
    # -- command --
    def call(case_id, case_has_new_activity)
      e = Cases::ActivityEvent

      Cases::ActivityChannel.broadcast_to(
        Partner::Repo.get.find_cohere.id,
        e.new(
          name: e::HasNewActivity,
          data: e::CaseActivity.new(
            case_id: case_id,
            case_has_new_activity: case_has_new_activity,
          ),
        )
      )
    end

    alias :perform :call
  end
end
