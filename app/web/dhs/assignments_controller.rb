module Dhs
  class AssignmentsController < Cases::BaseController
    # -- actions --
    def create
      @case = case_repo.find_for_dhs(params[:case_id])
      if policy.forbid?(:create_assignment)
        return deny_access
      end

      @case.assign_user(user)
      case_repo.save_new_assignment(@case)

      redirect_to(cases_path,
        notice: "You've been assigned to #{@case.recipient.profile.name}'s case."
      )
    end
  end
end
