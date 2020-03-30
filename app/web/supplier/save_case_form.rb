module Supplier
  class SaveCaseForm < ::ApplicationForm
    # -- lifetime --
    def initialize(
      form,
      case_repo: Case::Repo.get,
      user_repo: User::Repo.get,
      partner_repo: Partner::Repo.get
    )
      @form = form
      @case_repo = case_repo
      @user_repo = user_repo
      @partner_repo = partner_repo
    end

    # -- command --
    def call
      if not @form.valid?
        return false
      end

      # open a new case for the recipient
      opened_case = Case.open(
        recipient_profile: @form.map_to_recipient_profile,
        enroller: @partner_repo.find_default_enroller,
        supplier_user: @user_repo.find_current,
        supplier_account: @form.map_to_case_supplier_account,
      )

      @case_repo.save_opened(opened_case)
      true
    end
  end
end
