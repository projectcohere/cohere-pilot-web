module Cases
  class SupplierController < ApplicationController
    # -- filters --
    before_action(:check_case_scope)

    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        deny_access
      end
    end

    def new
      if policy.forbid?(:create)
        deny_access
      end

      @form = Cases::SupplierForm.new
    end

    def create
      if policy.forbid?(:create)
        deny_access
      end

      supplier_id = Current.user.role.organization_id

      @form = Cases::SupplierForm.new(nil, supplier_id,
        params
          .require(:case)
          .permit(Cases::SupplierForm.attribute_names)
      )

      # render errors if form failed to save
      if not @form.save
        flash.now[:alert] = "Please check the case for errors."
        render(:new)
        return
      end

      redirect_to(cases_supplier_index_path, notice: "Created case!")
    end

    # -- queries --
    private def policy
      @policy ||= Case::Policy.new(Current.user)
    end
  end
end
