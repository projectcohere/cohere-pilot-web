module Cohere
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      permit!(:list)

      @scope = Cases::Scope.from_key(params[:scope]) || Cases::Scope::All
      @page, @cases = view_repo.find_all_for_search(
        params[:search],
        page: params[:page]
      )
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
    end

    def edit
      permit!(:edit)

      @form = view_repo.edit_form(params[:id])
      @case = @form.detail
    end

    def update
      permit!(:edit)

      @form = view_repo.edit_form(params[:id], params: params)
      @case = @form.detail

      save_form = SaveCaseForm.new
      if not save_form.(@form)
        flash.now[:alert] = "Please check #{@case.recipient_name}'s case for errors."
        return render(:edit)
      end

      redirect_to(
        @case.detail_path(save_form.case.status),
        notice: "Updated #{@case.recipient_name}'s case!"
      )
    end

    def destroy
      permit!(:destroy)

      @case = case_repo.find(params[:id])
      case_repo.save_destroyed(@case)

      redirect_to(
        cases_path,
        notice: "Destroyed #{@case.recipient.profile.name}'s case."
      )
    end
  end
end
