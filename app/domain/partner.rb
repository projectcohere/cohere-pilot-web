class Partner < ::Entity
  # -- props --
  prop(:id)
  prop(:name)
  prop(:membership)
  prop(:programs)

  # -- queries --
  def find_program(program_id)
    return @programs.find { |p| p.id == program_id }
  end
end
