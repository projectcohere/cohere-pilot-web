class ApplicationController < ActionController::Base
  # -- modules --
  include Clearance::Controller
  include Authentication

  # -- config --
  default_form_builder(ApplicationFormBuilder)

  # -- filters --
  after_action(:process_events)

  # -- events --
  protected def event_queue
    EventQueue.get
  end

  protected def process_events
    Events::ProcessAll.get.()
  end

  # -- Clearance::Authentication --
  protected def url_after_denied_access_when_signed_in
    cases_path
  end
end
