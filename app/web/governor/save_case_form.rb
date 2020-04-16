module Governor
  class SaveCaseForm
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(form)
      if not form.valid?
        return false
      end

      @case = @case_repo.find_with_documents_for_governor(form.detail.id.val)
      @case.add_governor_data(form.map_to_recipient_household)
      @case_repo.save_dhs_contribution(@case)
      true
    end
  end
end
