module Cohere
  class SaveReferralForm
    def initialize(referral, form, action, case_repo: Case::Repo.get)
      @case_repo = case_repo
      @referral = referral
      @form = form
      @action = action
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

      @referral.referred.add_cohere_data(
        @form.map_to_case_supplier_account,
        @form.map_to_recipient_profile,
        @form.map_to_recipient_dhs_account,
      )

      # sign the contract if necessary
      selected_contract = @form.details.selected_contract
      if not selected_contract.nil?
        @referral.referred.sign_contract(selected_contract)
      end

      case @action
      when :submit
        @referral.referred.submit_to_enroller
      end

      @case_repo.save_referral(@referral)
      true
    end
  end
end
