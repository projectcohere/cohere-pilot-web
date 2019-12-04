module Cases
  class EnrollerController < ApplicationController
    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        deny_access
        return
      end

      @cases = Case::Repo.get.find_all_for_enroller(
        User::Repo.get.find_current.role.organization_id
      )
    end

    def complete
      # find the case
      user_repo = User::Repo.get
      case_repo = Case::Repo.get

      @case = case_repo.find_by_enroller_with_documents(
        params[:case_id],
        user_repo.find_current.role.organization_id
      )

      if policy.forbid?(:edit_status)
        deny_access
        return
      end

      # whitelist params
      case_params = params.require(:case).permit(:status)
      case_status = case_params[:status]&.to_sym

      if case_status != Case::Status::Approved && case_status != Case::Status::Denied
        flash.now[:alert] = "May only approve or deny the case."
        render(:show)
        return
      end

      # complete the case
      @case.complete(case_status)
      case_repo.save_completed(@case)

      redirect_to(cases_path,
        notice: "#{status.to_s.capitalize} #{@case.recipient.profile.name}'s case!"
      )
    end

    def show
      @case = Case::Repo.get.find_by_enroller_with_documents(
        params[:id],
        User::Repo.get.find_current.role.organization_id
      )

      if policy.forbid?(:view)
        deny_access
        return
      end

      events << Events::DidViewEnrollerCase.from_entity(@case)
    end

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
