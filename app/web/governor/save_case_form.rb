module Governor
  class SaveCaseForm
    def initialize(kase, form, case_repo: Case::Repo.get)
      @case_repo = case_repo
      @case = kase
      @form = form
    end

    # -- command --
    def call
      if not @form.valid?
        return false
      end

      @case.add_dhs_data(@form.map_to_recipient_dhs_account)
      @case_repo.save_dhs_contribution(@case)
      true
    end
  end
end