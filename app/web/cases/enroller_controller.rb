module Cases
  class EnrollerController < ApplicationController
    # -- filters --
    before_action(:check_case_scope)

    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        deny_access
      end

      @cases = Case::Repo.get.find_all_for_enroller(
        Current.user.role.organization_id
      )
    end

    def show
      @case = Case::Repo.get.find_for_enroller(
        params[:id],
        Current.user.role.organization_id
      )

      policy.case = @case
      if policy.forbid?(:view)
        deny_access
      end
    end

    # -- queries --
    private def policy
      @policy ||= Case::Policy.new(Current.user)
    end
  end
end
