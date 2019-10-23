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

      repo = Case::Repo.new
      @cases = Case::Repo.new.find_opened
    end

    def edit
      repo = Case::Repo.new
      kase = repo.find_one_opened(params[:id])

      if policy(kase).forbid?(:edit)
        deny_access
      end

      @form = Case::Forms::Opened.new(kase)
    end

    def update
      repo = Case::Repo.new
      kase = repo.find_one_opened(params[:id])

      if policy(kase).forbid?(:edit)
        deny_access
      end

      @form = Case::Forms::Opened.new(kase,
        params
          .require(:case)
          .permit(Case::Forms::Opened.params_shape)
      )

      if @form.save
        redirect_to(cases_path)
      else
        render(:edit)
      end
    end

    private

    # -- commands --
    def check_scope
      if policy.forbid?(:some)
        deny_access
      end
    end

    # -- queries --
    def policy(kase = nil)
      @policy ||= Case::Policy.new(
        Current.user,
        kase,
        scope: :opened
      )
    end
  end
end
