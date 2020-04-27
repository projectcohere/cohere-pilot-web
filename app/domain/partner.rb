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

  def default_role
    return case @membership
    when Membership::Cohere
      Role::Agent
    when Membership::Governor
      Role::Governor
    when Membership::Supplier
      Role::Source
    when Membership::Enroller
      Role::Enroller
    end
  end
end
