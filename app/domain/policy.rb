class Policy
  # -- lifetime --
  def initialize(user, settings: Settings.get)
    @user = user
    @settings = settings
  end

  # -- queries --
  # checks if the given user / scope is allowed to perform an action.
  def permit?(action)
    # TODO: policies are mixing application and domain concerns (or perhaps
    # they are purely application concerns). need to figure out how to draw
    # the line.
    case action
    when :list_cases
      true
    when :list_queue
      agent? || enroller? || governor?
    when :list_search
      agent? || enroller? || governor?
    when :list_reports
      admin? || enroller?
    when :admin
      agent? && admin?
    else
      false
    end
  end

  # checks if the given user / scope is forbidden from performing
  # an action
  def forbid?(action)
    return !permit?(action)
  end

  # -- queries --
  protected def admin?
    return @user.admin?
  end

  protected def role
    return @user.role
  end

  delegate(:source?, :governor?, :agent?, :enroller?, to: :role)

  protected def membership
    return @user.partner.membership
  end

  delegate(:supplier?, to: :membership)
end
