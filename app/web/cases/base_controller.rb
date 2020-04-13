module Cases
  class BaseController < ApplicationController
    helper(BaseHelper)
    helper_method(:policy)
    helper_method(:partner_id)

    # -- queries --
    protected def case_repo
      return Case::Repo.get
    end

    protected def view_repo
      return Cases::ViewRepo.get(@scope)
    end

    protected def user
      return User::Repo.get.find_current
    end

    protected def partner_id
      return user.role.partner_id
    end

    protected def policy
      return Case::Policy.new(user, @case)
    end
  end
end
