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
      events.add(Cases::Events::DidViewSourceForm.from_entity(@case))
    end

    def new
      permit!(:create)

      @form = view_repo.new_form(params[:temp_id], params[:program_id])
      @case = @form.model
    rescue ActiveRecord::RecordNotFound
      redirect_to(select_cases_path)
    end

    def create
      permit!(:create)

      @form = view_repo.new_form(
        params[:temp_id],
        params.dig(:case, :program_id),
        params: params
      )

      @case = @form.model

      if not SaveCaseForm.(@form)
        flash.now[:alert] = "Please check the case for errors."
        return render(:new)
      end

      redirect_to(cases_path, notice: "Created case!")
    rescue ActiveRecord::RecordNotFound
      redirect_to(select_cases_path)
    end

    def show
      permit!(:view)

      @case = view_repo.find_detail(params[:id])
    end
  end
end
