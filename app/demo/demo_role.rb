class DemoRole < ::Option
  # -- options --
  option(:applicant)
  option(:call_center)
  option(:state)
  option(:nonprofit)

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

  # -- factories --
  def self.from_demo_id(demo_id)
    case demo_id[0]
    when "a"
      return DemoRole::Applicant
    when "c"
      return DemoRole::CallCenter
    when "s"
      return DemoRole::State
    when "n"
      return DemoRole::Nonprofit
    end
  end
end
