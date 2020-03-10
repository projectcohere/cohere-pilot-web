class Stats
  class Case < ::Value
    LocalTimeZone = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")

    # -- props --
    prop(:supplier)
    prop(:status)
    prop(:created_at)
    prop(:completed_at)

    # -- queries --
    def approved?
      return @status == ::Case::Status::Approved
    end

    def same_day_determination?
      return to_local_date(@created_at) === to_local_date(@completed_at)
    end

    def minutes_to_determination
      return ((completed_at - created_at) / 60).round
    end

    # -- queries/helpers
    private def to_local_date(time)
      return time.in_time_zone(LocalTimeZone).to_date
    end
  end
end
