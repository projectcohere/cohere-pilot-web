class Id
  # -- props --
  attr(:val)

  # -- lifetime --
  def initialize(val)
    @val = val
  end

  # -- commands --
  def set(val)
    @val = val
  end

  # -- queries --
  def to_s
    return @val.to_s
  end

  # -- equality --
  def ==(id)
    return id.is_a?(Id) && val == id.val
  end

  # -- constants --
  None = Id.new(nil)
end
