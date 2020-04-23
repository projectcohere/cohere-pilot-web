module Cohere
  class ReferralsController < Cases::BaseController
    # -- actions --
    def select
      permit!(:referral)
      @case = view_repo.new_pending_referral(params[:case_id])
    end

    def new
      permit!(:referral)

      if params[:program_id].blank?
        return redirect_to(case_path(id: params[:case_id]))
      end

      referrer = case_repo
        .find_with_associations(params[:case_id])

      program = program_repo
        .find(params[:program_id])

      referral = referrer
        .make_referral(program)

      @form = view_repo.new_form(referral.referred)
      @case = @form.detail
    end

    def create
      permit!(:referral)

      referrer = case_repo
        .find_with_associations(params[:case_id])

      program = program_repo
        .find(params.dig(:case, :program_id))

      referral = referrer.make_referral(
        program,
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

    # -- queries --
    private def program_repo
      return Program::Repo.get
    end
  end
end
