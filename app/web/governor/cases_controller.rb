module Governor
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @scope = Cases::Scope::All
      @page, @cases = view_repo.find_all_for_search(page: params[:page])
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

    def edit
      if policy.forbid?(:edit)
        return deny_access
      end

      @form = view_repo.edit_form(params[:id])
      @case = @form.detail

      events.add(Cases::Events::DidViewGovernorForm.from_entity(@case))
    end

    def update
      if policy.forbid?(:edit)
        return deny_access
      end

      @form = view_repo.edit_form(params[:id])
      @case = @form.detail

      save_form = SaveCaseForm.new
      if not save_form.(@form)
        flash.now[:alert] = "Please check the case for errors."
        return render(:edit)
      end

      redirect_to(cases_path, notice: "Case updated!")
    end
  end
end
