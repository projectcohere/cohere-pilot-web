class Supplier
  class SaveCasesForm < ::ApplicationForm
    # -- lifetime --
    def initialize(
      form,
      case_repo: Case::Repo.get,
      enroller_repo: Enroller::Repo.get,
      supplier_repo: Supplier::Repo.get
    )
      @form = form
      @case_repo = case_repo
      @enroller_repo = enroller_repo
      @supplier_repo = supplier_repo
    end

    # -- command --
    def call
      if not @form.valid?
        return false
      end

      # open a new case for the recipient
      enroller = @enroller_repo.find_default
      supplier = @supplier_repo.find_current

      new_case = supplier.open_case(enroller,
        account: @form.map_to_case_supplier_account,
        profile: @form.map_to_recipient_profile,
      )

      @case_repo.save_opened(new_case)
      true
    end
  end
end
