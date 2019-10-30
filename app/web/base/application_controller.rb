class ApplicationController < ActionController::Base
  # -- modules --
  include Clearance::Controller
  include ::Authentication

  # -- config --
  default_form_builder(ApplicationFormBuilder)

  # -- helpers --
  helper_method(:root_path_by_permissions)

  protected

  # -- Clearance::Authentication --
  def url_after_denied_access_when_signed_in
    root_path_by_permissions
  end
end
