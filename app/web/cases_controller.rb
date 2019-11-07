class CasesController < ApplicationController
  # -- filters --
  before_action(:check_case_scope)

  # -- helpers --
  helper_method(:policy)

  # -- actions --
  def index
    if policy.forbid?(:list)
      deny_access
    end

    @cases = Case::Repo.get.find_all_incomplete
  end

  def edit
    kase = Case::Repo.get.find(params[:id])

    policy.case = kase
    if policy.forbid?(:edit)
      deny_access
    end

    @form = Cases::Form.new(kase)
  end

  def update
    kase = Case::Repo.get.find(params[:id])

    policy.case = kase
    if policy.forbid?(:edit)
      deny_access
    end

    @form = Cases::Form.new(kase,
      params
        .require(:case)
        .permit(Cases::Form.params_shape)
    )

    if not @form.save
      flash.now[:alert] = "Please check #{@form.name}'s case for errors."
      render(:edit)
      return
    end

    redirect_to(cases_path, notice: "Updated #{@form.name}'s case!")
  end

  # -- queries --
  private def policy
    @policy ||= Case::Policy.new(Current.user)
  end
end
