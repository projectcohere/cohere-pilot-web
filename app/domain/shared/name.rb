class Name < ::Value
  # -- props --
  prop(:first)
  prop(:last)

  # -- queries --
  def to_s
    return "#{first} #{last}"
  end
end
