class Stats
  class Supplier < ::Value
    # -- props --
    prop(:id)
    prop(:name)

    # -- comparison --
    include Comparable

    def ==(other)
      other.is_a?(Supplier) && @id == other.id
    end

    def <=>(other)
      return other.is_a?(Supplier) ? @id <=> other.id : -1
    end
  end
end
