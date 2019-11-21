module Cases
  class EnrollerController < ApplicationController
    # -- helpers --
    helper_method(:policy)

    # -- actions --
    def index
      if policy.forbid?(:list)
        deny_access
      end

      @cases = Case::Repo.get.find_all_for_enroller(
        User::Repo.get.find_current.role.organization_id
      )
    end

    def show
      @case = Case::Repo.get.find_by_enroller_with_documents(
        params[:id],
        User::Repo.get.find_current.role.organization_id
      )

      policy.case = @case
      if policy.forbid?(:view)
        deny_access
      end
    end

    # -- queries --
    private def policy
      @policy ||= Case::Policy.new(User::Repo.get.find_current)
    end
  end
end
