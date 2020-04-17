module Cohere
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @scope = Cases::Scope.from_key(params[:scope]) || Cases::Scope::All
      @page, @cases = view_repo.find_all_for_search(
        params[:search],
        page: params[:page]
      )
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
      if policy.forbid?(:view)
        return deny_access
      end

      @case = view_repo.find_detail(params[:id])
    end

    def edit
      if policy.forbid?(:edit)
        return deny_access
      end

      @form = view_repo.edit_form(params[:id])
      @case = @form.detail
    end

    def update
      if policy.forbid?(:edit)
        return deny_access
      end

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
      @case = case_repo.find(params[:id])
      if policy.forbid?(:destroy)
        return deny_access
      end

      case_repo.save_destroyed(@case)
      redirect_to(
        cases_path,
        notice: "Destroyed #{@case.recipient.profile.name}'s case."
      )
    end

    # -- helpers --
    private def chat_repo
      return Chat::Repo.get
    end
  end
end
