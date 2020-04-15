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
      when :list_queue
        cohere? || enroller? || governor?
      # create
      when :create
        supplier?
      when :create_assignment
        cohere? || enroller? || governor?
      # edit
      when :edit
        cohere? || governor?
      when :edit_supplier
        cohere?
      when :edit_ownership
        cohere? && wrap?
      when :edit_primary_residence
        cohere? && wrap?
      when :edit_supplier_account_active
        cohere? && wrap?
      # view
      when :view
        cohere? || enroller?
      when :view_fpl
        cohere? || enroller?
      when :view_ownership
        cohere? && wrap?
      when :view_primary_residence
        cohere? && wrap?
      when :view_supplier_account_active
        cohere? && wrap?
      # actions
      when :referral
        cohere?
      when :complete
        cohere? || enroller?
      # destroy
      when :destroy
        cohere?
      when :destroy_assignment
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
    delegate(:meap?, :wrap?, to: :program, private: :true)

    private def program
      return @case.program
    end
  end
end
