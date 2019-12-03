class CasesController < ApplicationController
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
    @case = Case::Repo.get.find_with_documents(params[:id])

    if policy.forbid?(:edit)
      deny_access
    end

    @form = Cases::Form.new(@case)
  end

  def update
    @case = Case::Repo.get.find_with_documents(params[:id])
    if policy.forbid?(:edit)
      deny_access
    end

    @form = Cases::Form.new(@case,
      params
        .require(:case)
        .permit(Cases::Form.params_shape)
    )

    if not @form.save
      flash.now[:alert] = "Please check #{@form.name}'s case for errors."
      render(:edit)
      return
    end

    redirect_to(cases_path,
      notice: "Updated #{@form.name}'s case!"
    )
  end

  def submit
    @case = Case::Repo.get.find_with_documents(params[:case_id])
    if policy.forbid?(:edit_status)
      deny_access
      return
    end

    @form = Cases::Form.new(@case, {
      "status" => :submitted
    })

    if not @form.save
      flash.now[:alert] = "Please check #{@form.name}'s case for errors."
      render(:edit)
      return
    end

    redirect_to(cases_path,
      notice: "Submitted #{@form.name}'s case!"
    )
  end

  def complete
    case_repo = Case::Repo.get

    @case = case_repo.find_with_documents(params[:case_id])
    if policy.forbid?(:edit_status)
      deny_access
      return
    end

    @form = Cases::Form.new(@case,
      params
        .require(:case)
        .permit(:status)
    )

    if not @form.save
      flash.now[:alert] = "May only approve or deny the case."
      render(:edit)
      return
    end

    redirect_to(cases_path,
      notice: "#{status.to_s.capitalize} #{@case.recipient.profile.name}'s case!"
    )
  end

  # -- queries --
  private def policy
    Case::Policy.new(User::Repo.get.find_current, @case)
  end
end
