module Cases
  class ActivityEvent < ::Value
    # -- props --
    prop(:name)
    prop(:data)

    # -- names --
    HasNewActivity = "HAS_NEW_ACTIVITY".freeze
    AddCaseToQueue = "ADD_CASE_TO_QUEUE".freeze

    # -- payloads --
    class NewCase < ::Value
      prop(:case_id)
      prop(:case_html)
    end

    class CaseActivity < ::Value
      prop(:case_id)
      prop(:case_has_new_activity)
    end
  end
end
