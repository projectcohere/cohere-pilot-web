class Case
  class Policy < ::Policy
    # -- lifetime --
    def initialize(user, kase = nil)
      @case = kase
      super(user)
    end

    # -- queries --
    # checks if the given user/case is allowed to perform an action.
    def permit?(action)
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
        super
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

    # -- queries --
    private def meap?
      @case.program == Program::Name::Meap
    end

    private def wrap?
      @case.program == Program::Name::Wrap
    end
  end
end
