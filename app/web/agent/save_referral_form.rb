module Agent
  class SaveReferralForm < ::Command
    attr(:case)

    # -- lifetime --
    def initialize(
      user_repo: User::Repo.get,
      case_repo: Case::Repo.get
    )
      @user_repo = user_repo
      @case_repo = case_repo
    end

    # -- command --
    def call(form, referral)
      if not form.valid?
        return false
      end

      @case = referral.referred

      # populate the case
      @case.add_agent_data(
        form.map_to_profile,
        form.map_to_household,
        form.map_to_supplier_account,
        form.map_to_food,
        form.map_to_benefit,
      )

      @case.add_admin_data(
        form.map_to_admin
      )

      # assign the current user
      @case.assign_user(@user_repo.find_current)

      # sign the contract if necessary
      contract = form.map_to_contract
      if contract != nil
        @case.sign_contract(contract)
      end

      # process actions if specified
      case form.action
      when :submit
        @case.submit_to_enroller
      end

      @case_repo.save_referral(referral)
      true
    end
  end
end
