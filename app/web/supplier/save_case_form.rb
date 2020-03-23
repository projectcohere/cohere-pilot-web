module Supplier
  class SaveCaseForm < ::ApplicationForm
    # -- lifetime --
    def initialize(
      form,
      case_repo: Case::Repo.get,
      partner_repo: Partner::Repo.get
    )
      @form = form
      @case_repo = case_repo
      @partner_repo = partner_repo
    end

    # -- command --
    def call
      if not @form.valid?
        return false
      end

      # open a new case for the recipient
      supplier = @partner_repo.find_current_supplier
      enroller = @partner_repo.find_default_enroller

      new_case = supplier.open_case(enroller,
        account: @form.map_to_case_supplier_account,
        profile: @form.map_to_recipient_profile,
      )

      @case_repo.save_opened(new_case)
      true
    end
  end
end
