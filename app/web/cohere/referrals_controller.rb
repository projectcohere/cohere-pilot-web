module Cohere
  class ReferralsController < ApplicationController
    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def new
      @case = Case::Repo.get.find_with_documents_and_referral(params[:case_id])
      if policy.forbid?(:referral)
        deny_access
        return
      end

      referral = @case.make_referral_to_program(
        Program::Name::Wrap
      )

      @case = referral.referred
      @view = Cases::View.new(@case)
      @form = CasesForm.new(@case)
    end

    def create
      @case = Case::Repo.get.find_with_documents_and_referral(params[:case_id])
      if policy.forbid?(:referral)
        deny_access
        return
      end

      case_params = params
        .require(:case)
        .permit(CasesForm.params_shape)

      referral = @case.make_referral_to_program(
        Program::Name::Wrap,
        supplier_id: case_params.dig(:supplier_account, :supplier_id)
      )

      @case = referral.referred
      @view = Cases::View.new(@case)
      @form = CasesForm.new(@case, case_params)

      save_form = SaveReferralForm.new(referral, @form, save_action)
      if not save_form.()
        flash.now[:alert] = "Please check the case for errors."
        render(:new)
        return
      end

      redirect_to(edit_case_path(@case.id), notice: "Created referral!")
    end

    # -- queries --
    private def save_action
      if params.key?(:submit)
        :submit
      end
    end

    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
