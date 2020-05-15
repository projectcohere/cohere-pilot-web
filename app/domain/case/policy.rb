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
      # -- list
      when :list
        permit?(:list_cases)

      # -- create
      when :create
        source? && @settings.working_hours?
      when :create_assignment
        agent? || enroller? || governor?
      when :create_note
        agent? || enroller?

      # -- edit
      when :edit
        agent? || governor?
      when :edit_contract
        agent? && requirement?(&:contract_present?)
      when :edit_address
        agent? || source?
      when :edit_contact
        agent? || source?
      when :edit_address_geography
        source?
      when :edit_household
        agent? || governor? || permit?(:edit_household_source)
      when :edit_household_source
        permit?(:edit_household_ownership) || permit?(:edit_household_proof_of_income)
      when :edit_household_size
        agent? || governor?
      when :edit_household_ownership
        (agent? || source?) && requirement?(&:household_ownership?)
      when :edit_household_proof_of_income
        (agent? || source?) && !requirement?(&:household_proof_of_income_dhs?)
      when :edit_household_dhs_number
        (agent? || governor?) && proof_of_income?(&:dhs?)
      when :edit_household_size
        agent? || governor?
      when :edit_household_income
        (agent? || governor?) && proof_of_income?(&:dhs?)
      when :edit_supplier_account
        (agent? || source?) && requirement?(&:supplier_account_present?)
      when :edit_supplier
        agent? || (source? && !supplier?)
      when :edit_supplier_account_active_service
        agent? && requirement?(&:supplier_account_active_service?)
      when :edit_documents
        agent?
      when :edit_admin
        agent?

      # -- view
      when :view
        agent? || source? || enroller?
      when :view_details
        permit?(:view)
      when :view_details_status
        agent? || enroller?
      when :view_details_enroller
        agent?
      when :view_supplier_account
        permit?(:view) && requirement?(&:supplier_account_present?)
      when :view_household_size
        (agent? || enroller?)
      when :view_household_ownership
        permit?(:view) && requirement?(&:household_ownership?)
      when :view_household_proof_of_income
        (agent? || enroller?) && !requirement?(&:household_proof_of_income_dhs?)
      when :view_household_dhs_number
        (agent? || enroller?) && proof_of_income?(&:dhs?)
      when :view_household_income
        (agent? || enroller?) && proof_of_income?(&:dhs?)
      when :view_supplier_account_active_service
        (agent? || enroller?) && requirement?(&:supplier_account_active_service?)

      # -- actions
      when :convert
        agent?
      when :referral
        agent?
      when :complete
        agent? || enroller?

      # -- destroy
      when :destroy
        agent?
      when :destroy_assignment
        agent?

      # -- archive
      when :archive
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
    private def requirement?(&predicate)
      return @case.program.requirements.any?(&predicate)
    end

    private def proof_of_income?(&predicate)
      return predicate.(@case.household.proof_of_income)
    end
  end
end
