module Governor
  class SaveCaseForm < ::Command
    # -- lifetime --
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(form)
      if not form.valid?
        return false
      end

      case_id = form.model.id.val

      # add governor data to the case
      @case = @case_repo.find_with_associations(case_id)
      @case.add_governor_data(form.map_to_household)

      # save the case
      @case_repo.save_governor_data(@case)

      return true
    end
  end
end
