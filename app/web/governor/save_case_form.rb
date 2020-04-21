module Governor
  class SaveCaseForm < ::Command
    include Cases::Authorization

    # -- lifetime --
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(form)
      if not form.valid?
        return false
      end

      case_id = form.detail.id.val

      # add governor data to the case
      @case = @case_repo.find_with_documents_for_governor(case_id, user_partner_id)
      @case.add_governor_data(form.map_to_recipient_household)

      # save the case
      @case_repo.save_dhs_contribution(@case)

      return true
    end
  end
end
