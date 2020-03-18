class Enroller
  class CasesController < ApplicationController
    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @page, @cases = Case::Repo.get.find_all_for_enroller(
        User::Repo.get.find_current.role.organization_id,
        page: params[:page],
      )
    end

    def complete
      @case = Case::Repo.get.find_by_enroller_with_documents(
        params[:case_id],
        User::Repo.get.find_current.role.organization_id
      )

      if policy.forbid?(:edit_status)
        return deny_access
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
        return deny_access
      end

      events.add(Cases::Events::DidViewEnrollerCase.from_entity(@case))
    end

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
