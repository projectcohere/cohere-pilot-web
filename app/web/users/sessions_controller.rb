module Users
  class SessionsController < Clearance::SessionsController
    include ::Authentication

    # clearance doesn't respect standard pathing
    prepend_view_path("app/views/users")

    protected

    # -- Clearance::SessionsController --
    def url_after_create
      build_user
      case_scope.rewrite_path(cases_path)
    end
  end
end
