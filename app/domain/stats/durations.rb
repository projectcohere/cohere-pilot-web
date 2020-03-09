class Stats
  class Durations < ::Value
    # -- props --
    prop(:count)
    prop(:dhs)
    prop(:enroller)
    prop(:recipient)

    # -- queries --
    def max_avg_seconds
      all = [@dhs.avg_seconds, @enroller.avg_seconds, @recipient.avg_seconds]
      return all.max
    end
  end
end
