module Cases
  class ActivityEvent < ::Value
    # -- props --
    prop(:name)
    prop(:data)

    # -- names --
    def self.has_new_activity(case_id, case_has_new_activity)
      return ActivityEvent.new(
        name: "HAS_NEW_ACTIVITY",
        data: {
          case_id: case_id,
          case_has_new_activity: case_has_new_activity,
        },
      )
    end

    def self.did_add_queued_case(case_id)
      return ActivityEvent.new(
        name: "DID_ADD_QUEUED_CASE",
        data: {
          case_id: case_id,
        },
      )
    end
  end
end
