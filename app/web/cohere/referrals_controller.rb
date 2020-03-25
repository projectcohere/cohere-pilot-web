module Cohere
  class ReferralsController < ApplicationController
    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def new
      @case = Case::Repo.get.find_with_documents_and_referral(params[:case_id])
      if policy.forbid?(:referral)
        return deny_access
      end

      referral = @case.make_referral_to_program(
        Program::Name::Wrap
      )

      @case = referral.referred
      @chat = Chat::Repo.get.find_by_recipient_with_messages(@case.recipient.id.val)
      @form = CaseForm.new(@case)
    end

    def create
      @case = Case::Repo.get.find_with_documents_and_referral(params[:case_id])
      if policy.forbid?(:referral)
        return deny_access
      end

      case_params = params
        .require(:case)
        .permit(CaseForm.params_shape)

      referral = @case.make_referral_to_program(
        Program::Name::Wrap,
        supplier_id: case_params.dig(:supplier_account, :supplier_id)
      )

      @case = referral.referred
      @chat = Chat::Repo.get.find_by_recipient_with_messages(@case.recipient.id.val)
      @form = CaseForm.new(@case, case_params)

      save_action = %i[submit].find do |key|
        params.key?(key)
      end

      save_form = SaveReferralForm.new(referral, @form, save_action)
      if not save_form.()
        flash.now[:alert] = "Please check the case for errors."
        return render(:new)
      end

      redirect_to(edit_case_path(@case.id), notice: "Created referral!")
    end

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
