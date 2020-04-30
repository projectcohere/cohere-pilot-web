module Agent
  class AssignmentsController < Cases::BaseController
    # -- actions --
    def create
      permit!(:create_assignment)

      @case = case_repo.find(params[:case_id])
      @case.assign_user(user)
      case_repo.save_new_assignment(@case)

      redirect_to(
        queue_cases_path,
        notice: "You've been assigned to #{@case.recipient.profile.name}'s case."
      )
    end

    def destroy
      permit!(:destroy_assignment)

      @case = case_repo.find_with_assignment(params[:case_id], params[:partner_id])
      email = @case.selected_assignment.user_email
      @case.destroy_selected_assignment
      case_repo.save_destroyed_assignment(@case)

      redirect_to(
        edit_case_path(@case),
        notice: "You've unassigned #{email} from #{@case.recipient.profile.name}'s case."
      )
    end
  end
end
