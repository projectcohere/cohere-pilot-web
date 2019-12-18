module Cohere
  class SaveCaseForm
    def initialize(kase, form, action, case_repo: Case::Repo.get)
      @case_repo = case_repo
      @case = kase
      @form = form
      @action = action
    end

    # -- command --
    def call
      scopes = []
      if @action == :submit || @case.submitted?
        scopes << :submitted
      end

      if @action == :complete
        scopes << :completed
      end

      if not @form.valid?(scopes)
        return false
      end

      @case.add_cohere_data(
        @form.map_to_case_supplier_account,
        @form.map_to_recipient_profile,
        @form.map_to_recipient_dhs_account,
      )

      # sign the contract if necessary
      selected_contract = @form.details.selected_contract
      if not selected_contract.nil?
        @case.sign_contract(selected_contract)
      end

      case @action
      when :submit
        @case.submit_to_enroller
      when :remove
        @case.remove_from_pilot
      when :approve
        @case.complete(Case::Status::Approved)
      when :deny
        @case.complete(Case::Status::Denied)
      end

      @case_repo.save_cohere_contribution(@case)
      true
    end
  end
end
