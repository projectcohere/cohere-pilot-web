class Stats
  class Quantity < ::Value
    # -- props --
    prop(:filter)
    prop(:count)
    prop(:total)

    # -- queries --
    def ratio
      if @total == nil || @total == 0
        return 0.0
      end

      return @count.to_f / @total
    end

    # -- comparison --
    include Comparable

    def ==(other)
      return other.is_a?(Quantity) && @filter == other.filter && @count == other.count
    end

    def <=>(other)
      return other.is_a?(Quantity) ? @filter <=> other.filter : other
    end
  end
end
