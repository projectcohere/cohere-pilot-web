class SessionsController < Clearance::SessionsController
  include ::Authentication

  protected

  # -- Clearance::SessionsController --
  def url_after_create
    build_user
    case_scope.scoped_path(cases_path)
  end
end
