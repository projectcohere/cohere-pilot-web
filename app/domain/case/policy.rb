class Case
  class Policy
    # -- lifetime --
    def initialize(user, kase = nil, scope: :root)
      @user = user
      @scope = scope
      @case = kase
    end

    # -- queries --
    # checks if the given user / scope is allowed to perform
    # an action. if :some is passed as the action, just checks the
    # if the user has access to the scope.
    def permit?(action)
      role = @user.role

      # this can pattern match on [action, scope, role] in ruby 2.7
      # check scope permissions
      if @scope != scope_for_user
        return false
      end

      # then check action permissions
      case action
      when :some
        true
      when :list
        true
      when :edit
        role != :supplier && role != :enroller
      when :create
        role == :supplier
      when :view
        role == :enroller
      when :view_status
        role == :cohere
      else
        false
      end
    end

    # checks if the given user / scope is forbidden from performing
    # an action
    def forbid?(action)
      not permit?(action)
    end

    # infers the allowed scope based on the user's role
    def scope_for_user
      case @user.role
      when :supplier
        :supplier
      when :dhs
        :dhs
      when :enroller
        :enroller
      when :cohere
        :root
      else
        nil
      end
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
