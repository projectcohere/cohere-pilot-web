class Program < ::Value
  # -- props --
  prop(:id)
  prop(:name)
  prop(:contracts)
  prop(:requirements)

  # -- queries --
  def requirement?(requirement)
    return @requirements.include?(requirement)
  end
end
