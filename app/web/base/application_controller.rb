class ApplicationController < ActionController::Base
  # -- modules --
  include Clearance::Controller
  include Authentication

  # -- config --
  default_form_builder(ApplicationFormBuilder)

  protected

  # -- Clearance::Authentication --
  def url_after_denied_access_when_signed_in
    policy = Case::Policy.new(Current.user)

    if policy.permit?(:list)
      cases_path
    else
      inbound_cases_path
    end
  end
end
