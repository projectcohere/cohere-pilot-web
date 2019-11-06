module Cases
  class SubmittedController < ApplicationController
    # -- filters --
    before_action(:check_scope)

    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        deny_access
      end

      @cases = Case::Repo.get.find_for_enroller(
        Current.user.organization.id
      )
    end

    def show
      @case = Case::Repo.get.find_one_for_enroller(
        params[:id],
        Current.user.organization.id
      )

      policy.case = @case
      if policy.forbid?(:view)
        deny_access
      end
    end

    # -- commands --
    private def check_scope
      if not case_scope.scoped?
        deny_access
      end
    end

    # -- queries --
    private def policy
      case_scope.policy
    end

    private def case_scope
      @case_scope ||= CaseScope.new(:submitted, Current.user)
    end
  end
end
