module Program
  Meap = :meap
  Wrap = :wrap

  # -- queries --
  def self.all
    @all ||= constants.map { |n| const_get(n) }
  end
end
