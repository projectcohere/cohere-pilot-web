module Cohere
  class CasesController < ApplicationController
    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @scope = params[:scope]

      case @scope
      when "open"
        @cases = Case::Repo.get.find_all_opened
      when "completed"
        @cases = Case::Repo.get.find_all_completed
      end
    end

    def edit
      @case = Case::Repo.get.find_with_documents_and_referral(params[:id])
      if policy.forbid?(:edit)
        return deny_access
      end

      @chat = Chat::Repo.get.find_by_recipient_with_messages(@case.recipient.id.val)
      @view = Cases::View.new(@case)
      @form = CaseForm.new(@case)
    end

    def update
      @case = Case::Repo.get.find_with_documents_and_referral(params[:id])
      if policy.forbid?(:edit)
        return deny_access
      end

      @chat = Chat::Repo.get.find_by_recipient_with_messages(@case.recipient.id.val)
      @view = Cases::View.new(@case)
      @form = CaseForm.new(@case,
        params
          .fetch(:case, {})
          .permit(CaseForm.params_shape)
      )

      save_action = %i[submit approve deny remove].find do |key|
        params.key?(key)
      end

      save_form = SaveCaseForm.new(@case, @form, save_action)
      if not save_form.()
        flash.now[:alert] = "Please check #{@view.recipient_name}'s case for errors."
        return render(:edit)
      end

      redirect_path = if @case.complete?
        case_path(@case.id)
      else
        edit_case_path(@case.id)
      end

      redirect_to(redirect_path,
        notice: "Updated #{@view.recipient_name}'s case!"
      )
    end

    def show
      @case = Case::Repo.get.find_with_documents_and_referral(params[:id])

      if policy.forbid?(:view)
        return deny_access
      end
    end

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
