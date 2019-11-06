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

    @cases = Case::Repo.get.find_incomplete
  end

  def edit
    kase = Case::Repo.get.find_one(params[:id])

    policy.case = kase
    if policy.forbid?(:edit)
      deny_access
    end

    @form = Case::Forms::Full.new(kase)
  end

  def update
    kase = Case::Repo.get.find_one(params[:id])

    policy.case = kase
    if policy.forbid?(:edit)
      deny_access
    end

    @form = Case::Forms::Full.new(kase,
      params
        .require(:case)
        .permit(Case::Forms::Full.params_shape)
    )

    if not @form.save
      flash.now[:alert] = "Please check #{@form.name}'s case for errors."
      render(:edit)
      return
    end

    if @form.model.status == :submitted
      note = Case::Notes::SubmittedCase::Broadcast.new
      note.receiver_ids.each do |receiver_id|
        CasesMailer.submitted_case(@form.case_id, receiver_id).deliver_later
      end
    end

    redirect_to(cases_path, notice: "Updated #{@form.name}'s case!")
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
end
