module Enroller
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @scope = Cases::Scope::All
      @page, @cases = view_repo.find_all_for_search(params[:search], page: params[:page])
    end

    def queue
      if policy.forbid?(:list_queue)
        return deny_access
      end

      @scope = Cases::Scope.from_key(params[:scope]) || Cases::Scope::Assigned
      @page, @cases = case @scope
      when Cases::Scope::Assigned
        view_repo.find_all_assigned(page: params[:page])
      when Cases::Scope::Queued
        view_repo.find_all_queued(page: params[:page])
      end
    end

    def show
      @case = view_repo.find_detail(params[:id])
      if policy.forbid?(:view)
        return deny_access
      end

      events.add(Cases::Events::DidViewEnrollerCase.from_entity(@case))
    end

    def complete
      @case = case_repo.find_with_documents_for_enroller(params[:case_id], user_partner_id)
      if policy.forbid?(:complete)
        return deny_access
      end

      save_case = SaveCompletedCase.new(@case, params[:complete_action].to_sym)
      save_case.()

      redirect_to(case_path(@case),
        notice: "#{@case.status.to_s.capitalize} #{@case.recipient.profile.name}'s case!"
      )
    end
  end
end
