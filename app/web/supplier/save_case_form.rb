module Supplier
  class SaveCaseForm < ::Command
    include Cases::Authorization

    # -- props --
    attr(:case)

    # -- lifetime --
    def initialize(
      case_repo: Case::Repo.get,
      partner_repo: Partner::Repo.get
    )
      @case_repo = case_repo
      @partner_repo = partner_repo
    end

    # -- command --
    def call(form)
      if not form.valid?
        return false
      end

      # open a new case for the recipient
      @case = Case.open(
        recipient_profile: form.map_to_recipient_profile,
        enroller: @partner_repo.find_default_enroller,
        supplier: @partner_repo.find_current_supplier,
        supplier_account: form.map_to_supplier_account,
      )

      @case.assign_user(user)

      # save the new case
      @case_repo.save_opened(@case)

      return true
    end
  end
end
