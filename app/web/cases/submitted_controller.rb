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
      if policy.forbid?(:view)
        deny_access
      end

      user = Current.user
      repo = Case::Repo.new

      @case = repo.find_one_for_enroller(params[:id], user.organization.id)
    end

    private

    # -- commands --
    def check_scope
      if policy.forbid?(:some)
        deny_access
      end
    end

    # -- queries --
    def policy(kase = nil)
      @policy ||= Case::Policy.new(
        Current.user,
        kase,
        scope: :submitted
      )
    end
  end
end
