module Enroller
  class SaveCaseForm < ::Command
    attr(:case)

    # -- lifetime --
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(form)
      if not form.valid?
        return false
      end

      # populate the case
      @case = @case_repo.find_with_associations(form.model.id.val)

      # process actions if specified
      status = case form.action
      when Cases::Action::Approve
        Case::Status::Approved
      when Cases::Action::Deny
        Case::Status::Denied
      end

      if status != nil
        @case.complete(status, form.map_to_benefit)
      end

      @case_repo.save_completed(@case)
      true
    end
  end
end
