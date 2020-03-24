module Enroller
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @scope = Cases::Scope.from_key(params[:scope])
      @page, @cases = case @scope
      when Cases::Scope::Queued
        case_repo.find_all_queued_for_enroller(enroller_id, page: params[:page])
      when Cases::Scope::Assigned
        case_repo.find_all_assigned_by_user(user.id, page: params[:page])
      when Cases::Scope::Submitted
        case_repo.find_all_submitted_for_enroller(enroller_id, page: params[:page])
      end
    end

    def complete
      @case = case_repo.find_with_documents_for_enroller(params[:case_id], enroller_id)
      if policy.forbid?(:complete)
        return deny_access
      end

      save_case = SaveCompletedCase.new(@case, params[:complete_action].to_sym)
      save_case.()

      redirect_to(case_path(@case),
        notice: "#{@case.status.to_s.capitalize} #{@case.recipient.profile.name}'s case!"
      )
    end

    def show
      @case = case_repo.find_with_documents_for_enroller(params[:id], enroller_id)
      if policy.forbid?(:view)
        return deny_access
      end

      events.add(Cases::Events::DidViewEnrollerCase.from_entity(@case))
    end

    # -- helpers --
    private def enroller_id
      return user.role.partner_id
    end
  end
end
