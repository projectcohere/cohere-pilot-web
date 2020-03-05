class Stats
  class Segment < ::Value
    # -- props --
    prop(:filter)
    prop(:count)
    prop(:total)

    # -- queries --
    def ratio
      return @count.to_f / @total
    end

    # -- comparison --
    include Comparable

    def ==(other)
      return other.is_a?(Segment) && @filter == other.filter && @count == other.count
    end

    def <=>(other)
      return other.is_a?(Segment) ? @filter <=> other.filter : other
    end
  end
end
