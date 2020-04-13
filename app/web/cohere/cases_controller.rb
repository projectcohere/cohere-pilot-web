module Cohere
  class CasesController < Cases::BaseController
    # -- actions --
    def index
      if policy.forbid?(:list)
        return deny_access
      end

      @scope = Cases::Scope.from_key(params[:scope]) || Cases::Scope::All
      @page, @cases = view_repo.find_all_for_search(
        params[:search],
        partner_id,
        page: params[:page],
      )
    end

    def queue
      if policy.forbid?(:list_queue)
        return deny_access
      end

      @scope = Cases::Scope.from_key(params[:scope]) || Cases::Scope::Assigned
      @page, @cases = case @scope
      when Cases::Scope::Assigned
        view_repo.find_all_assigned_to_user(user.id, page: params[:page])
      when Cases::Scope::Queued
        view_repo.find_all_queued_for_cohere(partner_id, page: params[:page])
      end
    end

    def edit
      @case = case_repo.find_with_associations(params[:id])
      if policy.forbid?(:edit)
        return deny_access
      end

      @chat = chat_repo.find_by_recipient_with_messages(@case.recipient.id.val)
      @form = CaseForm.new(@case)
    end

    def update
      @case = case_repo.find_with_associations(params[:id])
      if policy.forbid?(:edit)
        return deny_access
      end

      @chat = chat_repo.find_by_recipient_with_messages(@case.recipient.id.val)
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
        flash.now[:alert] = "Please check #{@case.recipient.profile.name}'s case for errors."
        return render(:edit)
      end

      redirect_path = if @case.complete?
        case_path(@case.id)
      else
        edit_case_path(@case.id)
      end

      redirect_to(redirect_path,
        notice: "Updated #{@case.recipient.profile.name}'s case!"
      )
    end

    def show
      @case = case_repo.find_with_associations(params[:id])
      @chat = chat_repo.find_by_recipient_with_messages(@case.recipient.id.val)

      if policy.forbid?(:view)
        return deny_access
      end
    end

    def destroy
      @case = case_repo.find(params[:id])
      if policy.forbid?(:destroy)
        return deny_access
      end

      case_repo.save_destroyed(@case)

      redirect_to(cases_path,
        notice: "Destroyed #{@case.recipient.profile.name}'s case."
      )
    end

    # -- helpers --
    private def chat_repo
      return Chat::Repo.get
    end
  end
end
