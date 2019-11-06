module Cases
  class OpenedController < ApplicationController
    # -- filters --
    before_action(:check_scope)

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

      @form = Case::Forms::Opened.new(kase)
    end

    def update
      repo = Case::Repo.get
      kase = repo.find_opened(params[:id])

      policy.case = kase
      if policy.forbid?(:edit)
        deny_access
      end

      @form = Case::Forms::Opened.new(kase,
        params
          .require(:case)
          .permit(Case::Forms::Opened.params_shape)
      )

      if @form.save
        redirect_to(cases_opened_index_path, notice: "Case updated!")
      else
        render(:edit)
      end
    end

    # -- commands --
    private def check_scope
      if not case_scope.scoped?
        deny_access
      end
    end

    # -- queries --
    private def policy
      case_scope.policy
    end

    def case_scope
      @case_scope ||= CaseScope.new(:opened, Current.user)
    end
  end
end
