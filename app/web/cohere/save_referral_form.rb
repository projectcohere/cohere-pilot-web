module Cohere
  class SaveReferralForm < ::Command
    def initialize(
      referral,
      form,
      action,
      user_repo: User::Repo.get,
      case_repo: Case::Repo.get
    )
      @referral = referral
      @form = form
      @action = action
      @user_repo = user_repo
      @case_repo = case_repo
    end

    # -- command --
    def call
      scopes = []
      if @action == :submit
        scopes << :submitted
      end

      if not @form.valid?(scopes)
        return false
      end

      referred = @referral.referred
      referred.add_cohere_data(
        @form.map_to_supplier_account,
        @form.map_to_recipient_profile,
        @form.map_to_recipient_household,
      )

      # assign the current user
      referred.assign_user(@user_repo.find_current)

      # sign the contract if necessary
      selected_contract = @form.details.selected_contract
      if not selected_contract.nil?
        referred.sign_contract(selected_contract)
      end

      # process actions if specified
      case @action
      when :submit
        referred.submit_to_enroller
      end

      @case_repo.save_referral(@referral)
      true
    end
  end
end
