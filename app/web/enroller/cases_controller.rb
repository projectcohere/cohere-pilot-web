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
      @case = Case::Repo.get.find_by_enroller_with_documents(
        params[:case_id],
        User::Repo.get.find_current.role.organization_id
      )

      if policy.forbid?(:edit_status)
        deny_access
        return
      end

      save_case = SaveCompletedCase.new(@case, params[:complete_action].to_sym)
      save_case.()

      redirect_to(case_path(@case),
        notice: "#{@case.status.to_s.capitalize} #{@case.recipient.profile.name}'s case!"
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
