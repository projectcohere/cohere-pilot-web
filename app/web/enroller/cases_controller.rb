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
    end

    def edit
      permit!(:edit)

      @form = view_repo.edit_form(params[:id])
      @case = @form.model
      events.add(Cases::Events::DidViewEnrollerForm.from_entity(@case))
    end

    def update
      permit!(:edit)

      @form = view_repo.edit_form(params[:id], params: params)
      @case = @form.model

      save_form = SaveCaseForm.new
      if not save_form.(@form)
        flash.now[:alert] = t(".flashes.failure", name: @case.recipient_name)
        return render(:edit)
      end

      if @form.action == nil
        redirect_to(
          @case.detail_path(save_form.case),
          notice: t(".flashes.success", name: @case.recipient_name),
        )
      else
        redirect_to(
          @case.list_path,
          notice: t(".flashes.action", action: @form.action_text, name: @case.recipient_name),
        )
      end
    end

    def return
      permit!(:complete)

      @case = ReturnCaseToAgent.(params[:case_id])
      redirect_to(cases_path, notice: t(".flash", name: name))
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
