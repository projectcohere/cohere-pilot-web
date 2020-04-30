module Agent
  class SaveCaseForm < ::Command
    attr(:case)

    # -- lifetime --
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(form)
      if not form.valid?
        return false
      end

      # populate the case
      @case = @case_repo.find(form.model.id.val)

      # update the case
      @case.add_agent_data(
        form.map_to_supplier_account,
        form.map_to_recipient_profile,
        form.map_to_recipient_household,
      )

      @case.add_admin_data(
        form.map_to_admin
      )

      # sign the contract if necessary
      selected_contract = form.details.selected_contract
      if not selected_contract.nil?
        @case.sign_contract(selected_contract)
      end

      # process actions if specified
      case form.action
      when :submit
        @case.submit_to_enroller
      when :remove
        @case.remove_from_pilot
      when :approve
        @case.complete(Case::Status::Approved)
      when :deny
        @case.complete(Case::Status::Denied)
      end

      @case_repo.save_agent_data(@case)
      true
    end
  end
end
