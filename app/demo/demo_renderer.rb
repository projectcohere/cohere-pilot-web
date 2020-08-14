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

  def a01_phone
    setup(demo_id: "a01")
    @chat = @repo.find_applicant_chat(step: 0)
    return render("demo/phone", path: "/")
  end

  def a02_legal
    setup(demo_id: "a02")
    @chat = @repo.find_applicant_chat(step: 1)
    return render("demo/phone", path: "/")
  end

  def a03_id
    setup(demo_id: "a03")
    @chat = @repo.find_applicant_chat(step: 2)
    return render("demo/phone", path: "/")
  end

  def s01_sign_in
    setup(demo_id: "s01")

    @params = {
      email: @repo.find_source_user.email,
      password: "password123$",
    }

    return render("users/sessions/new", path: "/sign-in")
  end

  def s02_source_list
    setup(demo_id: "s02", user: @repo.find_source_user)

    @scope = Cases::Scope::All
    @page, @cases = @repo.find_source_cases

    return render("source/cases/index", path: "/cases")
  end

  def s03_source_start_case
    setup(demo_id: "s03", user: @repo.find_source_user)

    @scope = Cases::Scope::All
    @page, @cases = @repo.find_source_cases

    return render("source/cases/index", path: "/cases")
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
