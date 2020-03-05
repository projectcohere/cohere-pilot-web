class Stats
  class Case < ::Value
    # -- props --
    prop(:supplier)
    prop(:status)
    prop(:created_at)
    prop(:completed_at)

    # -- queries --
    def approved?
      return @status == ::Case::Status::Approved
    end

    def minutes_to_enroll
      return ((completed_at - created_at) / 60).round
    end
  end
end
