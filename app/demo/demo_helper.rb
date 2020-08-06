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
  def demo_coachmark_tag(anchor:, &children)
    content_tag = capture(&children)

    coachmark_tag = tag.div(
      id: "demo-coachmark",
      class: "DemoCoachmark DemoCoachmark--#{anchor}",
      data: { "demo-anchor": anchor },
    ) do
      tag.p(class: "DemoCoachmark-popup") do
        content_tag
      end
    end

    return coachmark_tag
  end
end
