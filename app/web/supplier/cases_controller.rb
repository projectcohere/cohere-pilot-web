module Supplier
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @scope = Cases::Scope::Open
      @page, @cases = case_repo.find_all_opened_for_supplier(partner_id, page: params[:page])
    end

    def new
      if policy.forbid?(:create)
        return deny_access
      end

      @form = CaseForm::new
      events.add(Cases::Events::DidViewSupplierForm.new)
    end

    def create
      if policy.forbid?(:create)
        return deny_access
      end

      @form = CaseForm.new(nil,
        params
          .require(:case)
          .permit(CaseForm.params_shape)
      )

      save_form = SaveCaseForm.new(@form)
      if not save_form.()
        flash.now[:alert] = "Please check the case for errors."
        return render(:new)
      end

      redirect_to(cases_path, notice: "Created case!")
    end
  end
end
