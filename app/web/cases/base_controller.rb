module Cases
  class BaseController < ApplicationController
    include Case::Policy::Context

    # -- view helpers --
    helper(BaseHelper)

    # -- commands --
    def permit!(key)
      if forbid?(key)
        deny_access
      end
    end

    # -- queries --
    protected def case_repo
      return Case::Repo.get
    end

    protected def view_repo
      return Cases::Views::Repo.get(@scope)
    end
  end
end
