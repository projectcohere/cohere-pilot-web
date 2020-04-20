class Program
  class Contract < ::Value
    # -- props --
    prop(:variant)

    # -- queries --
    def name
      return variant.to_s
    end
  end
end
