module Cases
  class ActivityEvent < ::Value
    # -- props --
    prop(:name)
    prop(:data)

    # -- names --
    AddCaseToQueue = :ADD_CASE_TO_QUEUE

    # -- payloads --
    class NewCase < ::Value
      prop(:case_id)
      prop(:case_html)
    end
  end
end
