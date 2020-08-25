class DemoRole < ::Option
  # -- props --
  prop(:pages)

  # -- options --
  option(:applicant, pages: 6)
  option(:call_center, pages: 6)
  option(:state, pages: 3)
  option(:nonprofit, pages: 9)

  # -- queries --
  def to_user_role
    role = case self
    when Applicant
      return Role::Enroller
    when CallCenter
      return Role::Source
    when State
      return Role::Governor
    when Nonprofit
      return Role::Agent
    end

    return role.to_s
  end

  def to_s
    return super.dasherize
  end
end
