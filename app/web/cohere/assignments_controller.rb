module Cohere
  class AssignmentsController < Cases::BaseController
    # -- actions --
    def create
      @case = case_repo.find(params[:case_id])
      if policy.forbid?(:create_assignment)
        return deny_access
      end

      @case.assign_user(user)
      case_repo.save_new_assignment(@case)

      redirect_to(cases_path,
        notice: "You've been assigned to #{Cases::View.new(@case).recipient_name}'s case."
      )
    end
  end
end
