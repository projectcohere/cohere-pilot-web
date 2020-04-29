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
        agent? || enroller? || governor?
      # create
      when :create
        source?
      when :create_assignment
        agent? || enroller? || governor?
      # edit
      when :edit
        agent? || governor?
      when :edit_details
        agent?
      when :edit_contract
        agent? && requires?(&:contract_present?)
      when :edit_address
        agent? || source?
      when :edit_contact
        agent? || source?
      when :edit_address_geography
        source?
      when :edit_household
        agent? || source? || governor?
      when :edit_household_size
        agent? || governor?
      when :edit_household_ownership
        agent? && requires?(&:household_ownership?)
      when :edit_household_primary_residence
        agent? && requires?(&:household_primary_residence?)
      when :edit_household_proof_of_income
        agent? || source?
      when :edit_household_dhs_number
        agent? || governor?
      when :edit_household_income
        agent? || governor?
      when :edit_supplier_account
        (agent? || source?) & requires?(&:supplier_account_present?)
      when :edit_supplier
        agent? || (source? && !supplier?)
      when :edit_supplier_account_active_service
        agent? && requires?(&:supplier_account_active_service?)
      when :edit_documents
        agent?
      when :edit_admin
        agent?
      # view
      when :view
        agent? || enroller?
      when :view_supplier_account
        (agent? || enroller?) && requires?(&:supplier_account_present?)
      when :view_fpl
        agent? || enroller?
      when :view_details_enroller
        agent?
      when :view_household_ownership
        agent? && requires?(&:household_ownership?)
      when :view_household_primary_residence
        agent? && requires?(&:household_primary_residence?)
      when :view_supplier_account_active_service
        agent? && requires?(&:supplier_account_active_service?)
      # actions
      when :referral
        agent?
      when :complete
        agent? || enroller?
      # destroy
      when :destroy
        agent?
      when :destroy_assignment
        agent?
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
      result = yield(self)
      @case = previous
      result
    end

    # -- queries --
    private def requires?(&predicate)
      return @case.program.requirements.any?(&predicate)
    end
  end
end
