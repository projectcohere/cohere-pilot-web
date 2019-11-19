class ApplicationController < ActionController::Base
  # -- modules --
  include Clearance::Controller
  include Authentication

  # -- config --
  default_form_builder(ApplicationFormBuilder)

  # -- helpers --
  helper_method(:case_scope)

  # -- filters --
  after_action(:process_events)

  # -- case-scope --
  # -- case-scope/queries
  protected def case_scope
    @case_scope ||= CaseScope.new(request.fullpath, User::Repo.get.find_current)
  end

  # -- case-scope/commands
  protected def check_case_scope
    if case_scope.reject?
      deny_access
    end
  end

  # -- events --
  protected def event_queue
    EventQueue.get
  end

  protected def process_events
    Events::ProcessAll.get.()
  end

  # -- Clearance::Authentication --
  protected def url_after_denied_access_when_signed_in
    if request.fullpath.start_with?(cases_path)
      case_scope.rewrite_path(request.fullpath)
    else
      case_scope.rewrite_path(cases_path)
    end
  end
end
