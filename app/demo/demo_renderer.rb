class DemoRenderer
  # -- lifetime --
  def initialize(repo:)
    @repo = repo
  end

  # -- pages --
  def landing
    setup(demo_id: "index")
    return render("demo/index", path: "/")
  end

  def a01_communication
    setup(demo_id: "a01")
    @chat = @repo.find_chat(step: 0)
    return render("demo/phone", path: "/")
  end

  def a02_legal
    setup(demo_id: "a02")
    @chat = @repo.find_chat(step: 1)
    return render("demo/phone", path: "/")
  end

  def a03_language
    setup(demo_id: "a03")
    @chat = @repo.find_chat(step: 2)
    return render("demo/phone", path: "/")
  end

  def a04_questions
    setup(demo_id: "a04")
    @chat = @repo.find_chat(step: 3)
    return render("demo/phone", path: "/")
  end

  def a05_documents
    setup(demo_id: "a05")
    @chat = @repo.find_chat(step: 4)
    return render("demo/phone", path: "/")
  end

  def a06_enrolled
    setup(demo_id: "a06")
    @chat = @repo.find_chat(step: 5)
    return render("demo/phone", path: "/")
  end

  def c01_sign_in
    setup(demo_id: "c01")

    @params = {
      email: @repo.find_source_user.email,
      password: "password123$",
    }

    return render("users/sessions/new", path: "/sign-in")
  end

  def c02_start_case
    setup(demo_id: "c02", user: @repo.find_source_user)
    @form = @repo.find_pending_case
    @case = @form.model
    return render("source/cases/select", path: "/cases/select")
  end

  def c03_form
    setup(demo_id: "c03", user: @repo.find_source_user)
    @form = @repo.find_new_case
    @case = @form.model
    return render("source/cases/new", path: "/cases/new")
  end

  def c04_state_data
    setup(demo_id: "c04", user: @repo.find_source_user)
    @form = @repo.find_new_case(filled: true)
    @case = @form.model
    return render("source/cases/new", path: "/cases/new")
  end

  def c05_begin_application
    setup(demo_id: "c05", user: @repo.find_source_user)
    @form = @repo.find_new_case(filled: true)
    @case = @form.model
    return render("source/cases/new", path: "/cases/new")
  end

  def c06_view_cases
    setup(demo_id: "c06", user: @repo.find_source_user)
    @scope = Cases::Scope::All
    @page, @cases = @repo.find_cases(@scope)
    return render("source/cases/index", path: "/cases")
  end

  def s01_case_alert
    setup(demo_id: "s01", user: @repo.find_state_user)
    @scope = Cases::Scope::Queued
    @page, @cases = @repo.find_cases(@scope)
    return render("governor/cases/queue", path: "/cases/inbox")
  end

  def s02_form
    setup(demo_id: "s02", user: @repo.find_state_user)
    @form = @repo.find_active_case(step: 0)
    @case = @form.model
    return render("governor/cases/edit", path: "/cases/1/edit")
  end

  def s03_fpl
    setup(demo_id: "s03", user: @repo.find_state_user)
    @form = @repo.find_active_case(step: 1)
    @case = @form.model
    return render("governor/cases/edit", path: "/cases/1/edit")
  end

  def n01_inbox
    setup(demo_id: "n01", user: @repo.find_nonprofit_user)
    @scope = Cases::Scope::Queued
    @page, @cases = @repo.find_cases(@scope)
    return render("agent/cases/queue", path: "/cases/inbox")
  end

  def n02_form
    setup(demo_id: "n02", user: @repo.find_nonprofit_user)
    @form = @repo.find_active_case(step: 1)
    @case = @form.model
    return render("agent/cases/edit", path: "/cases/1/edit")
  end

  def n03_chat
    setup(demo_id: "n03", user: @repo.find_nonprofit_user)
    @form = @repo.find_active_case(step: 2)
    @case = @form.model
    return render("agent/cases/edit", path: "/cases/1/edit")
  end

  def n04_macros
    setup(demo_id: "n04", user: @repo.find_nonprofit_user)
    @form = @repo.find_active_case(step: 3)
    @case = @form.model
    return render("agent/cases/edit", path: "/cases/1/edit")
  end

  def n05_documents
    setup(demo_id: "n05", user: @repo.find_nonprofit_user)
    @form = @repo.find_active_case(step: 4)
    @case = @form.model
    return render("agent/cases/edit", path: "/cases/1/edit#documents")
  end

  def n06_fpl
    setup(demo_id: "n06", user: @repo.find_nonprofit_user)
    @form = @repo.find_active_case(step: 4)
    @case = @form.model
    return render("agent/cases/edit", path: "/cases/1/edit")
  end

  def n07_determination
    setup(demo_id: "n07", user: @repo.find_nonprofit_user)
    @form = @repo.find_active_case(step: 4)
    @case = @form.model
    return render("agent/cases/edit", path: "/cases/1/edit")
  end

  def n08_referrals
    setup(demo_id: "n08", user: @repo.find_nonprofit_user)
    @form = @repo.find_referral_case
    @case = @form.model
    return render("agent/referrals/select", path: "/cases/1/referrals/select")
  end

  def n09_reports
    setup(demo_id: "n09", user: @repo.find_nonprofit_user)
    @form = @repo.find_report_form
    return render("reports/base/new", path: "/reports")
  end

  # -- helpers --
  private def setup(demo_id:, user: nil)
    @demo_id = demo_id

    # always activate working hours
    Settings.get.working_hours = true

    # sign in user if any
    if user != nil
      @repo.sign_in(user)
    end
  end

  private def render(template, path:)
    # create renderer with path
    r = renderer.new({ "PATH_INFO": path })

    # build map of ivars
    assigns = instance_variables.each_with_object({}) do |ivar, memo|
      next if ivar == :@repo
      name = ivar[1..-1] # remove @
      memo[name] = instance_variable_get(ivar)
    end

    # render template
    r.render(template, assigns: assigns)
  end

  # -- queries --
  delegate(:renderer, to: DemoController, private: true)
end
