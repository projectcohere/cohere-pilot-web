class Policy
  # -- lifetime --
  def initialize(user)
    @user = user
  end

  # -- queries --
  # checks if the given user / scope is allowed to perform an action.
  def permit?(action)
    return false
  end

  # checks if the given user / scope is forbidden from performing
  # an action
  def forbid?(action)
    return !permit?(action)
  end

  # -- queries --
  protected def role
    return @user.role
  end

  delegate(:source?, :governor?, :agent?, :enroller?, to: :role)

  protected def membership
    return @user.partner.membership
  end

  delegate(:supplier?, to: :membership)
end
