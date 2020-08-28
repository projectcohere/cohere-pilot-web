module DemoHelper
  # -- helpers --
  def demo?
    return @demo != nil && @demo
  end

  # -- types --
  DemoCookies = Struct.new(:signed)

  # -- overrides --
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

    return @demo_role&.to_user_role
  end

  def cookies
    return @cookies ||= DemoCookies.new({})
  end

  # -- tags --
  def demo_role_tag(demo_role)
    return tag.li(class: "DemoLanding-role Layout--#{demo_role.to_user_role}") do
      link_to(t("demo.role.#{demo_role}.name"), "/#{demo_role}/1") +
      tag.p(t("demo.role.#{demo_role}.body"))
    end
  end

  def demo_coachmark_tag(body = nil, anchor:, &children)
    content = block_given? ? capture(&children) : tag.p(body, class: "DemoCoachmark-body")

    coachmark_tag = tag.div(
      id: "demo-coachmark",
      class: "DemoCoachmark DemoCoachmark--#{anchor.to_s.underscore.camelcase(:lower)}",
      data: { "demo-anchor": anchor },
    ) do
      triangle_tag = tag.svg(class: "DemoCoachmark-arrow", viewBox: "0 0 8 16") do
        tag.path(d: "m0 8 8-8v16z")
      end

      content_tag = tag.div(class: "DemoCoachmark-content") do
        content + demo_coachmark_link_tag
      end

      triangle_tag + content_tag
    end

    return coachmark_tag
  end

  def demo_coachmark_link_tag
    if @demo_page >= @demo_role.pages
      return link_to(
        t("demo.actions.home"),
        "/",
        data: { demo: true },
        class: "DemoCoachmark-next"
      )
    else
      return link_to(
        t("demo.actions.next"),
        "/#{@demo_role}/#{@demo_page + 1}",
        data: { demo: true },
        class: "DemoCoachmark-next",
      )
    end
  end

  def demo_link_out_to(path, *args, **kwargs, &block)
    return link_to(
      path,
      *args,
      target: "_blank",
      rel: "noopener noreferrer",
      **kwargs,
      &block
    )
  end
end
