module Cases
  class BaseController < ApplicationController
    include Permissions

    # -- view helpers --
    helper(BaseHelper)
    helper_method(:policy)

    # -- queries --
    protected def case_repo
      return Case::Repo.get
    end

    protected def view_repo
      return Cases::Views::Repo.get(@scope)
    end
  end
end
