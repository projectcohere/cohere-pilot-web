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

      supplier = @partner_repo.find(user_partner_id)

      # validate program
      supplier_program = supplier.find_program(form.program_id)
      if supplier_program == nil
        form.errors.add(:program_id, "This is not one of the your programs.")
        return false
      end

      # open a new case for the recipient
      @case = Case.open(
        recipient_profile: form.map_to_recipient_profile,
        enroller: @partner_repo.find_default_enroller,
        supplier: supplier,
        supplier_program: supplier_program,
        supplier_account: form.map_to_supplier_account,
      )

      @case.assign_user(user)

      # save the new case
      @case_repo.save_opened(@case)

      return true
    end
  end
end
