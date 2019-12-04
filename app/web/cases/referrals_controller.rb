module Cases
  class ReferralsController < ApplicationController
    def new
      @case = Case::Repo.get.find_with_documents(params[:case_id])
      if policy.forbid?(:referral)
        deny_access
        return
      end

      @case = @case.make_referral_to_program(Case::Program::Wrap)
      @form = Cases::Form.new(@case)
    end

    # -- queries --
    private def policy
      Case::Policy.new(User::Repo.get.find_current, @case)
    end
  end
end
