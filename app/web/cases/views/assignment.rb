module Cases
  module Views
    # A Case read model for broadcasting an assignment notification
    class Assignment < ::Value
      # -- props --
      prop(:role)
      prop(:case_id)
      prop(:partner_id)
    end
  end
end
