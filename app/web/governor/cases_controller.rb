module Governor
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @scope = Cases::Scope::Open
      @page, @cases = case_repo.find_all_opened_for_governor(partner_id, page: params[:page])
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
        case_repo.find_all_queued_for_governor(partner_id, page: params[:page])
      end
    end

    def edit
      @case = case_repo.find_with_documents_for_governor(params[:id])
      if policy.forbid?(:edit)
        return deny_access
      end

      @form = CaseForm.new(@case)
      events.add(Cases::Events::DidViewGovernorForm.from_entity(@case))
    end

    def update
      @case = case_repo.find_with_documents_for_governor(params[:id])
      if policy.forbid?(:edit)
        return deny_access
      end

      @form = CaseForm.new(@case,
        params
          .require(:case)
          .permit(CaseForm.params_shape)
      )

      save_form = SaveCaseForm.new(@case, @form)
      if not save_form.()
        flash.now[:alert] = "Please check the case for errors."
        return render(:edit)
      end

      redirect_to(cases_path, notice: "Case updated!")
    end
  end
end