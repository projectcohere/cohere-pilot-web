module Source
  class SaveCaseForm < ::Command
    include User::Context

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

      program = form.model.program

      # open a new case for the recipient
      @case = Case.open(
        program: program,
        profile: form.map_to_profile,
        household: form.map_to_household,
        enroller: @partner_repo.find_default_enroller,
        supplier_account: form.map_to_supplier_account,
      )

      @case.assign_user(user)

      # save the new case
      @case_repo.save_opened(@case)

      return true
    end
  end
end
