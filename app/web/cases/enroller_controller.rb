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

    def approve
      complete(:approved)
    end

    def deny
      complete(:denied)
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
    end

    # -- actions/helpers
    private def complete(status)
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

      @case.complete(status)
      case_repo.save_completed(@case)

      redirect_to(cases_path,
        notice: "#{status.to_s.capitalize} #{@case.recipient.profile.name}'s case!"
      )
    end

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
