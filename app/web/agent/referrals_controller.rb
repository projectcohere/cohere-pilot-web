module Agent
  class ReferralsController < Cases::BaseController
    # -- actions --
    def select
      permit!(:referral)

      @form = view_repo.program_form(params[:case_id])
      @case = @form.model
    end

    def new
      permit!(:referral)

      program_id = params.dig(:case, :program_id)
      if program_id.blank?
        return redirect_to(case_path(id: params[:case_id]))
      end

      referral = case_repo
        .find_with_associations(params[:case_id])
        .make_referral(program_repo.find(program_id))

      @form = view_repo.referral_form(referral.referred)
      @case = @form.model
    end

    def create
      permit!(:referral)

      referral = case_repo
        .find_with_associations(params[:case_id])
        .make_referral(program_repo.find(params.dig(:case, :program_id)))

      @form = view_repo.referral_form(referral.referred, params: params)
      @case = @form.model

      save_form = SaveReferralForm.new
      if not save_form.(@form, referral)
        flash.now[:alert] = "Please check the case for errors."
        return render(:new)
      end

      redirect_to(
        @case.detail_path(save_form.case),
        notice: "Created referral!"
      )
    end

    # -- queries --
    private def program_repo
      return Program::Repo.get
    end
  end
end
