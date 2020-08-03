class DemoRenderer
  def initialize(repo:)
    @repo = repo
  end

  # -- pages --
  def s01_sign_in
    setup!
    return render("users/sessions/new")
  end

  def s02_source_list
    setup!
    sign_in(@repo.find_source_user)
    @scope = Cases::Scope::All
    @page, @cases = @repo.find_source_cases
    return render("source/cases/index")
  end

  # -- helpers --
  private def setup!
    Settings.get.working_hours = true
  end

  private def sign_in(user)
    @repo.sign_in(user)
  end

  private def render(template)
    assigns = instance_variables.each_with_object({}) do |ivar, memo|
      name = ivar[1..-1] # remove @
      memo[name] = instance_variable_get(ivar)
    end

    renderer.render(template, assigns: assigns)
  end

  # -- queries --
  delegate(:renderer, to: DemoController, private: true)
end
