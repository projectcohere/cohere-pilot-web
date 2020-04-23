module Supplier
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      permit!(:list)

      @scope = Cases::Scope::All
      @page, @cases = view_repo.find_all_for_search(page: params[:page])
    end

    def select
      permit!(:create)
      @case = view_repo.new_pending(user_partner_id)
    end

    def new
      permit!(:create)

      if params[:program_id].blank?
        return redirect_to(select_cases_path)
      end

      @form = view_repo.new_form(params: {
        case: params.permit(:program_id),
      })

      events.add(Cases::Events::DidViewSupplierForm.new)
    end

    def create
      permit!(:create)

      @form = view_repo.new_form(params: params)
      if not SaveCaseForm.(@form)
        flash.now[:alert] = "Please check the case for errors."
        return render(:new)
      end

      redirect_to(cases_path, notice: "Created case!")
    end
  end
end
