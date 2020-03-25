module Cases
  class PublishActivity < ApplicationWorker
    ## -- types --
    CaseActivity = Struct.new(
      :id,
      :hasNewActivity,
    )

    ## -- command --
    def call(case_id, case_has_new_activity)
      partner = Partner::Repo.get.find_cohere

      activity = CaseActivity.new(
        case_id,
        case_has_new_activity,
      )

      ActivityChannel.broadcast_to(partner.id, activity)
    end

    alias :perform :call
  end
end
