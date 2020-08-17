module DemoHelper
  def demo?
    return @demo_id != nil
  end

  def demo_role
    return DemoRole.from_demo_id(@demo_id)
  end

  # -- helpers --
  def params
    return @params || super
  end

  def signed_in?
    return user != nil
  end

  def user_role
    if signed_in?
      return super
    end

    return demo_role&.to_user_role
  end

  # -- tags --
  def demo_role_tag(demo_role)
    return tag.li(class: "DemoLanding-role Layout--#{demo_role.to_user_role}") do
      link_to(t("demo.role.#{demo_role}.name"), "/#{demo_role}/1") +
      tag.p(t("demo.role.#{demo_role}.body"))
    end
  end

  def demo_coachmark_tag(body = nil, anchor:, &children)
    content = body || capture(&children)

    coachmark_tag = tag.div(
      id: "demo-coachmark",
      class: "DemoCoachmark DemoCoachmark--#{anchor}",
      data: { "demo-anchor": anchor },
    ) do
      tag.p(class: "DemoCoachmark-popup") do
        content
      end
    end

    return coachmark_tag
  end
end
