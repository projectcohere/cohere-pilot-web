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

      user = Current.user
      repo = Case::Repo.new

      @cases = repo.find_for_enroller(user.organization.id)
    end

    def show
      user = Current.user
      repo = Case::Repo.new

      @case = repo.find_one_for_enroller(params[:id], user.organization.id)

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
