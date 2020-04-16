module Supplier
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @scope = Cases::Scope::All
      @page, @cases = view_repo.find_all_for_search(page: params[:page])
    end

    def new
      if policy.forbid?(:create)
        return deny_access
      end

      @form = view_repo.new_form
      events.add(Cases::Events::DidViewSupplierForm.new)
    end

    def create
      if policy.forbid?(:create)
        return deny_access
      end

      @form = view_repo.new_form(params: params)
      if not SaveCaseForm.(@form)
        flash.now[:alert] = "Please check the case for errors."
        return render(:new)
      end

      redirect_to(cases_path, notice: "Created case!")
    end
  end
end
