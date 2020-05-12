module Enroller
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      permit!(:list)

      @scope = Cases::Scope::Assigned
      @page, @cases = view_repo.find_all_assigned(page: params[:page])
    end

    def queue
      permit!(:list_queue)

      @scope = Cases::Scope::Queued
      @page, @cases = view_repo.find_all_queued(page: params[:page])
    end

    def search
      permit!(:list_search)

      @scope = Cases::Scope::All
      @page, @cases = view_repo.find_all_for_search(params[:search], page: params[:page])
    end

    def show
      permit!(:view)

      @case = view_repo.find_detail(params[:id])
      events.add(Cases::Events::DidViewEnrollerCase.from_entity(@case))
    end

    def return
      permit!(:complete)

      @case = ReturnCaseToAgent.(params[:case_id])
      redirect_to(cases_path, notice: t(".flash", name: name))
    end

    def complete
      permit!(:complete)

      @case = CompleteCase.(params[:case_id], params[:status])
      redirect_to(cases_path, notice: t(".flash", action: status_text, name: name))
    end

    # -- helpers --
    private def status_text
      return t("case.status.#{params[:status]}")
    end

    private def name
      return @case.recipient.profile.name
    end
  end
end
