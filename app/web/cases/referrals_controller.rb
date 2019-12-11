module Cases
  class ReferralsController < ApplicationController
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
      @form = Cases::Form::V2.new(@case)
    end

    def create
      @case = Case::Repo.get.find_with_documents_and_referral(params[:case_id])
      if policy.forbid?(:referral)
        deny_access
        return
      end

      case_params = params
        .require(:case)
        .permit(Cases::Form::V2.params_shape)

      referral = @case.make_referral_to_program(
        Program::Name::Wrap,
        supplier_id: case_params.dig(:supplier_account, :supplier_id)
      )

      @case = referral.referred
      @view = Cases::View.new(@case)
      @form = Cases::Form::V2.new(@case, case_params)

      save_form = Cases::Referrals::SaveForm.new(referral, @form, save_action)
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
