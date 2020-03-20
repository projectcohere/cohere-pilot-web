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
  end
end
