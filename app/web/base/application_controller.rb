class ApplicationController < ActionController::Base
  # -- modules --
  include Clearance::Controller
  include Authentication

  # -- config --
  default_form_builder(ApplicationFormBuilder)

  protected

  # -- Clearance::Authentication --
  def url_after_denied_access_when_signed_in
    case_scope.scoped_path(cases_path)
  end
end
