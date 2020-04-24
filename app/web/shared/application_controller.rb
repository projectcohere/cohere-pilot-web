class ApplicationController < ActionController::Base
  # -- modules --
  include Clearance::Controller
  include Authentication
  include Authorization

  # -- config --
  default_form_builder(ApplicationFormBuilder)

  # -- callbacks --
  before_action(:set_file_host)
  after_action(:dispatch_events)

  # -- helpers --
  helper_method(:user_membership)
  helper_method(:shows_navigation?)

  # -- config --
  private def set_file_host
    Files::Host.set_current!
  end

  # -- helpers --
  def show_navigation!
    @navigation_visible = true
  end

  def shows_navigation?
    signed_in? || @navigation_visible
  end

  # -- events --
  protected def events
    Events::DispatchAll.get.events
  end

  protected def dispatch_events
    Events::DispatchAll.()
  end

  # -- Clearance::Authentication --
  protected def url_after_denied_access_when_signed_in
    cases_path
  end
end
