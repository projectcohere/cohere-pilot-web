class Partner < ::Entity
  # -- props --
  prop(:id)
  prop(:name)
  prop(:membership)
  prop(:programs)

  # -- queries --
  def primary_program
    return programs.first
  end
end
