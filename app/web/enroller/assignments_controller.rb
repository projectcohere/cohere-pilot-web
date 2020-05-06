module Enroller
  class AssignmentsController < Cases::BaseController
    # -- actions --
    def create
      permit!(:create_assignment)

      @case = case_repo.find_for_enroller(params[:case_id], user_partner_id)
      @case.assign_user(user)
      case_repo.save_new_assignment(@case)

      redirect_to(
        queue_cases_path,
        notice: "You've been assigned to #{@case.recipient.profile.name}'s case."
      )
    end
  end
end
