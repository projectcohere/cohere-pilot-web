module Cases
  class BaseController < ApplicationController
    include Case::Policy::Context

    # -- types --
    class NotAuthorized < StandardError
      def to_s
        return "Sorry, you're not allowed to perform this action right now."
      end
    end

    # -- filters --
    rescue_from(NotAuthorized, with: :deny_access)

    # -- view helpers --
    helper(BaseHelper)

    # -- commands --
    def permit!(key)
      if forbid?(key)
        raise NotAuthorized
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
