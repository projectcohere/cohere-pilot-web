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
      # create
      when :create
        supplier?
      when :create_assignment
        cohere? || enroller? || dhs?
      # edit
      when :edit
        cohere? || dhs?
      when :edit_supplier
        cohere?
      when :edit_ownership
        cohere? && wrap?
      when :edit_is_primary_residence
        cohere? && wrap?
      when :edit_has_active_service
        cohere? && wrap?
      # view
      when :view
        cohere? || enroller?
      when :view_fpl
        cohere? || enroller?
      when :view_ownership
        cohere? && wrap?
      when :view_is_primary_residence
        cohere? && wrap?
      when :view_has_active_service
        cohere? && wrap?
      # actions
      when :referral
        cohere?
      when :complete
        cohere? || enroller?
      # destroy
      when :destroy
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
