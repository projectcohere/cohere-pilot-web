module Dhs
  class CasesController < ApplicationController
    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @page, @cases = Case::Repo.get.find_all_for_dhs(page: params[:page])
    end

    def edit
      @case = Case::Repo.get.find_opened_with_documents(params[:id])
      if policy.forbid?(:edit)
        return deny_access
      end

      @view = Cases::View.new(@case)
      @form = CaseForm.new(@case)

      events.add(Cases::Events::DidViewDhsForm.from_entity(@case))
    end

    def update
      @case = Case::Repo.get.find_opened_with_documents(params[:id])
      if policy.forbid?(:edit)
        return deny_access
      end

      @view = Cases::View.new(@case)
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

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
