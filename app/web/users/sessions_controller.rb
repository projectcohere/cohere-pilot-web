module Users
  class SessionsController < Clearance::SessionsController
    include ::Authentication

    # clearance doesn't respect standard pathing
    prepend_view_path("app/views/users")

    protected

    # -- Clearance::SessionsController --
    def url_after_create
      return cases_path
    end
  end
end
