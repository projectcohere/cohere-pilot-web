class Policy
  # -- lifetime --
  def initialize(user)
    @user = user
  end

  # -- queries --
  # checks if the given user / scope is allowed to perform an action.
  def permit?(action)
    false
  end

  # checks if the given user / scope is forbidden from performing
  # an action
  def forbid?(action)
    not permit?(action)
  end

  # -- queries --
  delegate(:cohere?, :governor?, :supplier?, :enroller?, to: :membership)

  private def membership
    return @user.role.membership
  end
end
