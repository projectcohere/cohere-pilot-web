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
  protected def supplier?
    @user.role_name == :supplier
  end

  protected def dhs?
    @user.role_name == :dhs
  end

  protected def cohere?
    @user.role_name == :cohere
  end

  protected def enroller?
    @user.role_name == :enroller
  end
end
