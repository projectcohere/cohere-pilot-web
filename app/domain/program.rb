module Program
  Meap = :meap
  Wrap = :wrap

  # -- queries --
  def self.all
    @all ||= [
      Meap,
      Wrap
    ]
  end
end
