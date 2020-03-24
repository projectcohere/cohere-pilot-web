module Cases
  class BaseController < ApplicationController
    helper(BaseHelper)
    helper_method(:policy)

    # -- queries --
    protected def user
      return User::Repo.get.find_current
    end

    protected def policy
      return Case::Policy.new(user, @case)
    end

    protected def case_repo
      return Case::Repo.get
    end
  end
end
