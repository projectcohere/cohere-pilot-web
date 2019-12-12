module Cases
  class DhsController < ApplicationController
    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        deny_access
      end

      @cases = Case::Repo.get.find_all_for_dhs
    end

    def edit
      @case = Case::Repo.get.find_opened_with_documents(params[:id])
      if policy.forbid?(:edit)
        deny_access
      end

      @form = Cases::DhsForm.new(@case)
      events << Events::DidViewDhsForm.from_entity(@case)
    end

    def update
      @case = Case::Repo.get.find_opened_with_documents(params[:id])
      if policy.forbid?(:edit)
        deny_access
      end

      @form = Cases::DhsForm.new(@case,
        params
          .require(:case)
          .permit(Cases::DhsForm.params_shape)
      )

      if @form.save
        redirect_to(cases_path, notice: "Case updated!")
      else
        render(:edit)
      end
    end

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
