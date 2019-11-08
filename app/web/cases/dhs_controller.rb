module Cases
  class DhsController < ApplicationController
    # -- filters --
    before_action(:check_case_scope)

    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        deny_access
      end

      @cases = Case::Repo.get.find_all_opened
    end

    def edit
      repo = Case::Repo.get
      kase = repo.find_opened(params[:id])

      policy.case = kase
      if policy.forbid?(:edit)
        deny_access
      end

      @form = Cases::DhsForm.new(kase)
    end

    def update
      repo = Case::Repo.get
      kase = repo.find_opened(params[:id])

      policy.case = kase
      if policy.forbid?(:edit)
        deny_access
      end

      @form = Cases::DhsForm.new(kase,
        params
          .require(:case)
          .permit(Cases::DhsForm.params_shape)
      )

      if @form.save
        redirect_to(cases_dhs_index_path, notice: "Case updated!")
      else
        render(:edit)
      end
    end

    # -- queries --
    private def policy
      @policy ||= Case::Policy.new(Current.user)
    end
  end
end