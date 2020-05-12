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
      @case = @case_repo.find_with_associations(form.model.id.val)

      # update the case
      @case.add_agent_data(
        form.map_to_supplier_account,
        form.map_to_profile,
        form.map_to_household,
      )

      @case.add_admin_data(
        form.map_to_admin
      )

      # sign the contract if necessary
      contract = form.map_to_contract
      if contract != nil
        @case.sign_contract(contract)
      end

      # process actions if specified
      case form.action
      when Cases::Action::Submit
        @case.submit_to_enroller
      when Cases::Action::Remove
        @case.remove
      when Cases::Action::Approve
        @case.complete(Case::Status::Approved)
      when Cases::Action::Deny
        @case.complete(Case::Status::Denied)
      end

      @case_repo.save_agent_data(@case)
      true
    end
  end
end
