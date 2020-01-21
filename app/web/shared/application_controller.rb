class ApplicationController < ActionController::Base
  # -- modules --
  include Clearance::Controller
  include Authentication

  # -- config --
  default_form_builder(ApplicationFormBuilder)

  # -- callbacks --
  before_action(:set_file_host)
  after_action(:process_events)

  # -- config --
  private def set_file_host
    Files::Host.set_current!
  end

  # -- events --
  protected def events
    Services.domain_events
  end

  protected def process_events
    Events::ProcessAll.get.()
  end

  # -- Clearance::Authentication --
  protected def url_after_denied_access_when_signed_in
    cases_path
  end
end
