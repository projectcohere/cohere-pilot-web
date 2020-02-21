module Cases
  class PublishActivity < ApplicationWorker
    ## -- types --
    Activity = Struct.new(
      :case_id,
      :case_has_new_activity,
    )

    ## -- command --
    def call(case_id, case_has_new_activity)
      activity = Activity.new(
        case_id,
        case_has_new_activity
      )

      ActivityChannel.broadcast_to(ActivityChannel::Active, activity)
    end

    alias :perform :call
  end
end
