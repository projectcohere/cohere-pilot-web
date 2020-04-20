module Cohere
  class ReferralsController < Cases::BaseController
    # -- actions --
    def new
      if policy.forbid?(:referral)
        return deny_access
      end

      referrer = case_repo
        .find_with_associations(params[:case_id])

      # NEXT: choose referral by dropdown
      referral = referrer
        .make_referral(referrer.program)

      @form = view_repo.new_form(referral.referred)
      @case = @form.detail
    end

    def create
      if policy.forbid?(:referral)
        return deny_access
      end

      referrer = case_repo
        .find_with_associations(params[:case_id])

      # NEXT: choose referral by dropdown
      referral = referrer.make_referral(
        referrer.program,
        supplier_id: params.dig(:case, :supplier_account, :supplier_id)
      )

      @form = view_repo.new_form(referral.referred, params: params)
      @case = @form.detail

      save_form = SaveReferralForm.new
      if not save_form.(@form, referral)
        flash.now[:alert] = "Please check the case for errors."
        return render(:new)
      end

      redirect_to(
        @case.detail_path(save_form.case.status),
        notice: "Created referral!"
      )
    end
  end
end
