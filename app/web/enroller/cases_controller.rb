class Enroller
  class CasesController < ApplicationController
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

      # determine status
      case_status = case params[:completion]&.to_sym
      when :approve
        Case::Status::Approved
      when :deny
        Case::Status::Denied
      end

      # complete the case
      @case.complete(case_status)
      case_repo.save_completed(@case)

      redirect_to(case_path(@case),
        notice: "#{case_status.to_s.capitalize} #{@case.recipient.profile.name}'s case!"
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

      events << Cases::Events::DidViewEnrollerCase.from_entity(@case)
    end

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
