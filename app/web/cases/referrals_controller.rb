module Cases
  class ReferralsController < ApplicationController
    def new
      @case = Case::Repo.get.find_with_documents_and_referral(params[:case_id])
      if policy.forbid?(:referral)
        deny_access
        return
      end

      @case = @case.make_referral_to_program(Program::Wrap)
      @form = Cases::Form.new(@case)
    end

    def create
      @case = Case::Repo.get.find_with_documents_and_referral(params[:case_id])
      if policy.forbid?(:referral)
        deny_access
        return
      end

      referrer = @case

      case_params = params
        .require(:case)
        .permit(Cases::Form.params_shape)

      @case = referrer.make_referral_to_program(
        Program::Wrap,
        supplier_id: case_params[:supplier_id]
      )

      @form = Cases::Form.new(@case, case_params)

      if not @form.save(referrer: referrer)
        flash.now[:alert] = "Please check the case for errors."
        render(:new)
        return
      end

      redirect_to(cases_path, notice: "Created referral!")
    end

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
