class Case
  class Policy
    # -- lifetime --
    def initialize(user, kase = nil)
      @user = user
      @case = kase
    end

    # -- queries --
    # checks if the given user/case is allowed to perform an action.
    def permit?(action)
      role = @user.role_name

      # then check action permissions
      case action
      when :list
        true
      when :edit
        role != :supplier && role != :enroller
      when :create
        role == :supplier
      when :view
        role == :enroller
      else
        false
      end
    end

    # checks if the given user / scope is forbidden from performing
    # an action
    def forbid?(action)
      not permit?(action)
    end

    # -- commands --
    def case=(kase)
      @case = kase
    end

    # changes the policy's record for the duration of the block
    def with_case(kase)
      previous = @case
      @case = kase
      result = yield
      @case = previous
      result
    end
  end
end
