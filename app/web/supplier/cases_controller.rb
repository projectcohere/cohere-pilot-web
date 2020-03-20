class Supplier
  class CasesController < ApplicationController
    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @page, @cases = Case::Repo.get.find_all_for_supplier(
        User::Repo.get.find_current.role.partner_id,
        page: params[:page],
      )
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

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current)
    end
  end
end
