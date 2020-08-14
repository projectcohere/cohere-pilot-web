module DemoHelper
  def demo?
    return @demo_id != nil
  end

  # -- helpers --
  def params
    @params || super
  end

  def signed_in?
    return user != nil
  end

  # -- tags --
  def demo_role_tag(demo_role, theme:)
    return tag.li(class: "DemoLanding-role Layout--#{theme.to_s}") do
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
