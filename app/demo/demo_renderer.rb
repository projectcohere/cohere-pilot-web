class DemoRenderer
  def s01_sign_in
    return renderer.render("users/sessions/new")
  end

  # -- queries --
  delegate(:renderer, to: DemoController, private: true)
end
