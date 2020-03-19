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
      when CaseScope::Open
        @page, @cases = Case::Repo.get.find_all_opened(page: params[:page])
      when CaseScope::Completed
        @page, @cases = Case::Repo.get.find_all_completed(page: params[:page])
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
      @chat = Chat::Repo.get.find_by_recipient_with_messages(@case.recipient.id.val)

      if policy.forbid?(:view)
        return deny_access
      end
    end

    def destroy
      case_repo = Case::Repo.get

      @case = case_repo.find(params[:id])
      if policy.forbid?(:destroy)
        return deny_access
      end

      case_repo.save_destroyed(@case)

      redirect_to(cases_path,
        notice: "Destroyed #{Cases::View.new(@case).recipient_name}'s case!"
      )
    end

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
