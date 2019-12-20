class Supplier
  class CasesController < ApplicationController
    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        deny_access
      end

      @cases = Case::Repo.get.find_all_for_supplier(
        User::Repo.get.find_current.organization_id
      )
    end

    def new
      if policy.forbid?(:create)
        deny_access
      end

      @form = CaseForm::new
      events << Cases::Events::DidViewSupplierForm.new
    end

    def create
      if policy.forbid?(:create)
        deny_access
      end

      @form = CaseForm.new(nil,
        params
          .require(:case)
          .permit(CaseForm.params_shape)
      )

      save_form = SaveCaseForm.new(@form)
      if not save_form.()
        flash.now[:alert] = "Please check the case for errors."
        render(:new)
        return
      end

      redirect_to(cases_path, notice: "Created case!")
    end

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current)
    end
  end
end