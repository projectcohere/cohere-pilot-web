module Governor
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

      @scope = Cases::Scope::Active
      @page, @cases = view_repo.find_all_for_search(params[:search], page: params[:page])
    end

    def edit
      permit!(:edit)

      @form = view_repo.edit_form(params[:id])
      @case = @form.model

      events.add(Cases::Events::DidViewGovernorForm.from_entity(@case))
    end

    def update
      permit!(:edit)

      @form = view_repo.edit_form(params[:id], params: params)
      @case = @form.model

      save_form = SaveCaseForm.new
      if not save_form.(@form)
        flash.now[:alert] = "Please check the case for errors."
        return render(:edit)
      end

      events.add(Cases::Events::DidSaveGovernorForm.from_entity(@case))

      redirect_to(cases_path, notice: "Case updated!")
    end
  end
end
