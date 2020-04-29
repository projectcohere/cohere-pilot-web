module Enroller
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      permit!(:list)

      @scope = Cases::Scope::All
      @page, @cases = view_repo.find_all_for_search(params[:search], page: params[:page])
    end

    def queue
      permit!(:list_queue)

      @scope = Cases::Scope.from_key(params[:scope]) || Cases::Scope::Assigned
      @page, @cases = case @scope
      when Cases::Scope::Assigned
        view_repo.find_all_assigned(page: params[:page])
      when Cases::Scope::Queued
        view_repo.find_all_queued(page: params[:page])
      end
    end

    def show
      permit!(:view)
      @case = view_repo.find_detail(params[:id])
      events.add(Cases::Events::DidViewEnrollerCase.from_entity(@case))
    end

    def complete
      permit!(:complete)

      @case = case_repo.find_with_documents_for_enroller(params[:case_id], user_partner_id)

      save_case = SaveCompletedCase.new(@case, params[:complete_action].to_sym)
      save_case.()

      redirect_to(case_path(@case),
        notice: "#{@case.status.to_s.capitalize} #{@case.recipient.profile.name}'s case!"
      )
    end
  end
end
