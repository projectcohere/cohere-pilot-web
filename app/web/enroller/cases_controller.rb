module Enroller
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @scope = Cases::Scope::Submitted
      @page, @cases = case_repo.find_all_submitted_for_enroller(partner_id, page: params[:page])
    end

    def queue
      if policy.forbid?(:list_queue)
        return deny_access
      end

      @scope = Cases::Scope.from_key(params[:scope]) || Cases::Scope::Assigned
      @page, @cases = case @scope
      when Cases::Scope::Assigned
        case_repo.find_all_assigned_by_user(user.id, page: params[:page])
      when Cases::Scope::Queued
        case_repo.find_all_queued_for_enroller(partner_id, page: params[:page])
      end
    end

    def complete
      @case = case_repo.find_with_documents_for_enroller(params[:case_id], partner_id)
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
      @case = case_repo.find_with_documents_for_enroller(params[:id], partner_id)
      if policy.forbid?(:view)
        return deny_access
      end

      events.add(Cases::Events::DidViewEnrollerCase.from_entity(@case))
    end
  end
end
