class SessionsController < Clearance::SessionsController
  include ::Authentication

  protected

  # -- Clearance::SessionsController --
  def url_after_create
    build_user
    root_path_by_permissions
  end
end
