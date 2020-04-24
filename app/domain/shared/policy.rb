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
  def membership
    return @user.role.membership
  end

  delegate(:cohere?, :governor?, :supplier?, :enroller?, to: :membership)
end
