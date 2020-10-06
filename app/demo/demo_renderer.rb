class DemoRenderer
  # -- lifetime --
  def initialize(repo:)
    @repo = repo
  end

  # -- pages --
  def landing
    setup()
    return render("demo/index", path: "/")
  end

  def a01_communication
    setup(demo_role: DemoRole::Applicant, demo_page: 1)
    @chat = @repo.find_chat(step: 0)
    return render("demo/phone", path: "/")
  end

  def a02_legal
    setup(demo_role: DemoRole::Applicant, demo_page: 2)
    @chat = @repo.find_chat(step: 1)
    return render("demo/phone", path: "/")
  end

  def a03_language
    setup(demo_role: DemoRole::Applicant, demo_page: 3)
    @chat = @repo.find_chat(step: 2)
    return render("demo/phone", path: "/")
  end

  def a04_questions
    setup(demo_role: DemoRole::Applicant, demo_page: 4)
    @chat = @repo.find_chat(step: 3)
    return render("demo/phone", path: "/")
  end

  def a05_documents
    setup(demo_role: DemoRole::Applicant, demo_page: 5)
    @chat = @repo.find_chat(step: 4)
    return render("demo/phone", path: "/")
  end

  def a06_enrolled
    setup(demo_role: DemoRole::Applicant, demo_page: 6)
    @chat = @repo.find_chat(step: 5)
    return render("demo/phone", path: "/")
  end

  def c01_sign_in
    setup(demo_role: DemoRole::CallCenter, demo_page: 1)

    @params = {
      email: @repo.find_source_user.email,
      password: "password123$",
    }

    return render("users/sessions/new", path: "/sign-in")
  end

  def c02_start_case
    setup(demo_role: DemoRole::CallCenter, demo_page: 2, user: @repo.find_source_user)
    @form = @repo.find_pending_case
    @case = @form.model
    return render("source/cases/select", path: "/cases/select")
  end

  def c03_form
    setup(demo_role: DemoRole::CallCenter, demo_page: 3, user: @repo.find_source_user)
    @form = @repo.find_new_case
    @case = @form.model
    return render("source/cases/new", path: "/cases/new")
  end

  def c04_state_data
    setup(demo_role: DemoRole::CallCenter, demo_page: 4, user: @repo.find_source_user)
    @form = @repo.find_new_case(filled: true)
    @case = @form.model
    return render("source/cases/new", path: "/cases/new")
  end

  def c05_view_cases
    setup(demo_role: DemoRole::CallCenter, demo_page: 5, user: @repo.find_source_user)
    @scope = Cases::Scope::All
    @page, @cases = @repo.find_cases(@scope)
    return render("source/cases/index", path: "/cases")
  end

  def s01_case_alert
    setup(demo_role: DemoRole::State, demo_page: 1, user: @repo.find_state_user)
    @scope = Cases::Scope::Queued
    @page, @cases = @repo.find_cases(@scope)
    return render("governor/cases/queue", path: "/cases/inbox")
  end

  def s02_form
    setup(demo_role: DemoRole::State, demo_page: 2, user: @repo.find_state_user)
    @form = @repo.find_active_case(step: 0, has_id: true)
    @case = @form.model
    return render("governor/cases/edit", path: "/cases/1/edit")
  end

  def s03_fpl
    setup(demo_role: DemoRole::State, demo_page: 3, user: @repo.find_state_user)
    @form = @repo.find_active_case(step: 1)
    @case = @form.model
    return render("governor/cases/edit", path: "/cases/1/edit")
  end

  def n01_inbox
    setup(demo_role: DemoRole::Nonprofit, demo_page: 1, user: @repo.find_nonprofit_user)
    @scope = Cases::Scope::Queued
    @page, @cases = @repo.find_cases(@scope)
    return render("agent/cases/queue", path: "/cases/inbox")
  end

  def n02_form
    setup(demo_role: DemoRole::Nonprofit, demo_page: 2, user: @repo.find_nonprofit_user)
    @form = @repo.find_active_case(step: 4)
    @case = @form.model
    return render("agent/cases/edit", path: "/cases/1/edit")
  end

  def n03_chat
    setup(demo_role: DemoRole::Nonprofit, demo_page: 3, user: @repo.find_nonprofit_user)
    @form = @repo.find_active_case(step: 4)
    @case = @form.model
    return render("agent/cases/edit", path: "/cases/1/edit")
  end

  def n04_macros
    setup(demo_role: DemoRole::Nonprofit, demo_page: 4, user: @repo.find_nonprofit_user)
    @form = @repo.find_active_case(step: 4)
    @case = @form.model
    return render("agent/cases/edit", path: "/cases/1/edit")
  end

  def n05_documents
    setup(demo_role: DemoRole::Nonprofit, demo_page: 5, user: @repo.find_nonprofit_user)
    @form = @repo.find_active_case(step: 4)
    @case = @form.model
    return render("agent/cases/edit", path: "/cases/1/edit#documents")
  end

  def n06_determination
    setup(demo_role: DemoRole::Nonprofit, demo_page: 6, user: @repo.find_nonprofit_user)
    @form = @repo.find_active_case(step: 4)
    @case = @form.model
    return render("agent/cases/edit", path: "/cases/1/edit")
  end

  def n07_referrals
    setup(demo_role: DemoRole::Nonprofit, demo_page: 7, user: @repo.find_nonprofit_user)
    @form = @repo.find_referral_case
    @case = @form.model
    return render("agent/referrals/select", path: "/cases/1/referrals/select")
  end

  def n08_reports
    setup(demo_role: DemoRole::Nonprofit, demo_page: 8, user: @repo.find_nonprofit_user)
    @form = @repo.find_report_form
    return render("reports/base/new", path: "/reports")
  end

  # -- helpers --
  private def setup(demo_role: nil, demo_page: nil, user: nil)
    @demo = true
    @demo_role = demo_role
    @demo_page = demo_page

    # set demo_id from first char of role and page number
    @demo_id = if demo_role != nil && demo_page != nil
      "#{demo_role.to_s[0]}#{demo_page.to_s.rjust(2, "0")}"
    end

    # always activate working hours
    Settings.get.working_hours = true

    # sign in user if any
    if user != nil
      @repo.sign_in(user)
    end
  end

  private def render(template, path:)
    # set time if possible
    chat = @repo.find_current_chat
    if chat != nil
      @demo_time = chat.messages.last&.timestamp
    end

    if @cases&.length > 0
      now = @cases[0].updated_at + 1.minute
      Time.redefine_singleton_method(:now) { now }
    end

    # create renderer with path
    r = renderer.new({ "PATH_INFO": path })

    # build map of ivars
    assigns = instance_variables.each_with_object({}) do |ivar, memo|
      next if ivar == :@repo
      name = ivar[1..-1] # remove @
      memo[name] = instance_variable_get(ivar)
    end

    # render template
    html = r.render(template, assigns: assigns)

    return html
  end

  # -- queries --
  delegate(:renderer, to: DemoController, private: true)
end
