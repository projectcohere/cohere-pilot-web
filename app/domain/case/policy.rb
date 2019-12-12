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
      program = @case&.program

      # then check action permissions
      case action
      when :list
        true
      when :create
        supplier?
      # edit
      when :edit
        cohere? || dhs?
      when :edit_supplier
        cohere?
      when :edit_status
        cohere? || enroller?
      when :edit_has_active_service
        cohere? && wrap?
      # view
      when :view
        cohere? || enroller?
      when :view_fpl
        cohere? || enroller?
      # actions
      when :referral
        cohere?
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

    # -- queries --
    private def supplier?
      @user.role_name == :supplier
    end

    private def dhs?
      @user.role_name == :dhs
    end

    private def cohere?
      @user.role_name == :cohere
    end

    private def enroller?
      @user.role_name == :enroller
    end

    private def meap?
      @case.program == Program::Name::Meap
    end

    private def wrap?
      @case.program == Program::Name::Wrap
    end
  end
end
