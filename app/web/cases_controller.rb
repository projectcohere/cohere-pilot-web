class CasesController < ApplicationController
  # -- filters --
  before_action(:check_scope)

  # -- helpers --
  helper_method(:policy)

  # -- actions --
  def index
    if policy.forbid?(:list)
      deny_access
    end

    user = Current.user
    repo = Case::Repo.new

    @cases = repo.find_incomplete
  end

  def edit
    repo = Case::Repo.new
    kase = repo.find_one(params[:id])

    if policy(kase).forbid?(:edit)
      deny_access
    end

    @form = Case::Forms::Full.new(kase)
  end

  def update
    repo = Case::Repo.new
    kase = repo.find_one(params[:id])

    if policy(kase).forbid?(:edit)
      deny_access
    end

    @form = Case::Forms::Full.new(kase,
      params
        .require(:case)
        .permit(Case::Forms::Full.params_shape)
    )

    if @form.save
      redirect_to(cases_path, notice: "Updated #{@form.name}'s case!")
    else
      flash.now[:alert] = "Please check #{@form.name}'s case for errors."
      render(:edit)
    end
  end

  # -- commands --
  private def check_scope
    if policy.forbid?(:some)
      deny_access
    end
  end

  # -- queries --
  private def policy(kase = nil)
    @policy ||= Case::Policy.new(
      Current.user,
      kase
    )
  end
end
