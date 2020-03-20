class Program
  module Name
    # -- options --
    Meap = :meap
    Wrap = :wrap

    # -- queries --
    def self.all
      @all ||= [
        Meap,
        Wrap,
      ]
    end

    def self.index(option)
      return all.find_index(option)
    end
  end
end
