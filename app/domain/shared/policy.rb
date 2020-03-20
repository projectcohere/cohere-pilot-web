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
  protected def cohere?
    return @user.role.cohere?
  end

  protected def dhs?
    return @user.role.dhs?
  end

  protected def supplier?
    return @user.role.supplier?
  end

  protected def enroller?
    return @user.role.enroller?
  end
end
