module ApplicationHelper
  # -- elements --
  def filter_for(id, is_selected: false, is_error: false)
    link_to(id.to_s.titlecase, "##{id}",
      class: cx("Filter", "is-selected" => is_selected, "is-error" => is_error),
      data: { turbolinks: false }
    )
  end

  def section_tag(title = nil, header_tag = :h2, *args, **kwargs, &children)
    a_class = kwargs.delete(:class)

    # pre-render children
    section_content = capture(&children)

    # render section tag
    section_class = cx(a_class, "Panel-section")

    tag.fieldset(*args, class: section_class, **kwargs) do
      section_title = "".html_safe

      if title.present?
        section_title = tag.h1(class: "Panel-sectionTitle") do
          tag.span(title)
        end
      end

      section_title + section_content
    end
  end

  def field_tag(name, title = nil, *args, errors: nil, **kwargs, &children)
    a_class = kwargs.delete(:class)

    # pre-render children
    field_content = capture(&children)

    # render field tag
    field_class = cx(a_class, "Field",
      "is-error" => errors.present?,
    )

    tag.label(name, *args, class: field_class, **kwargs) do
      hint_tag = tag.p(class: "Field-hint") do
        hint_text = tag.span(title || name.to_s.titlecase)
        hint_error = errors.present? ? tag.span(" #{errors}", class: "Field-errors") : ""
        hint_text + hint_error
      end

      hint_tag + tag.div(field_content, class: "Field-value")
    end
  end

  def field_value(value, fallback: nil)
    if not value.nil?
      value
    elsif not fallback.nil?
      tag.span(fallback, class: "Field-fallback")
    end
  end

  # -- queries --
  def errors?(*models)
    models.any? do |model|
      model.errors.present?
    end
  end

  # -- utilities --
  def cx(*classes, states)
    active_classes = classes.filter do |c|
      c.present?
    end

    if states.present?
      if not states.is_a?(Hash)
        active_classes << states
      else
        states.each do |key, is_active|
          if is_active
            active_classes << key
          end
        end
      end
    end

    active_classes.join(" ")
  end
end