module Cases
  class SupplierController < ApplicationController
    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        deny_access
      end

      @cases = Case::Repo.get.find_all_for_supplier(
        User::Repo.get.find_current.role.organization_id
      )
    end

    def new
      if policy.forbid?(:create)
        deny_access
      end

      @form = Cases::SupplierForm.new
      events << Events::DidViewSupplierForm.new
    end

    def create
      if policy.forbid?(:create)
        deny_access
      end

      @form = Cases::SupplierForm.new(nil,
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

      redirect_to(cases_path, notice: "Created case!")
    end

    # -- queries --
    private def policy
      @policy ||= Case::Policy.new(User::Repo.get.find_current)
    end
  end
end
