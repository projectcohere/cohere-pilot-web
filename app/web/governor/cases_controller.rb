module Governor
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      permit!(:list)

      @scope = Cases::Scope::All
      @page, @cases = view_repo.find_all_for_search(page: params[:page])
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

    def edit
      permit!(:edit)

      @form = view_repo.edit_form(params[:id])
      @case = @form.detail

      events.add(Cases::Events::DidViewGovernorForm.from_entity(@case))
    end

    def update
      permit!(:edit)

      @form = view_repo.edit_form(params[:id], params: params)
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
