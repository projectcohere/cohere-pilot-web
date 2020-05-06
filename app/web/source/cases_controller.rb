module Source
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      permit!(:list)

      @scope = Cases::Scope::All
      @page, @cases = view_repo.find_all_for_search(page: params[:page])
    end

    def select
      permit!(:create)

      @case = view_repo.new_program_picker(user_partner_id)
    end

    def new
      permit!(:create)

      program_id = params[:program_id]
      if program_id.blank?
        return redirect_to(select_cases_path)
      end

      @form = view_repo.new_form(program_id)
      @case = @form.model

      events.add(Cases::Events::DidViewSupplierForm.new)
    end

    def create
      permit!(:create)

      program_id = params.dig(:case, :program_id)

      @form = view_repo.new_form(program_id, params: params)
      @case = @form.model

      if not SaveCaseForm.(@form)
        flash.now[:alert] = "Please check the case for errors."
        return render(:new)
      end

      redirect_to(cases_path, notice: "Created case!")
    end
  end
end
