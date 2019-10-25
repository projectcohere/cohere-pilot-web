class ApplicationFormBuilder < ::ActionView::Helpers::FormBuilder
  def section(title, header_tag = :h2, *args, **kwargs, &children)
    a_class = kwargs.delete(:class)

    # render the children & tag
    f_class = "#{a_class} Form-section"
    content = @template.capture(&children)

    group(*args, class: f_class, **kwargs) do
      @template.content_tag(header_tag) { @template.tag.span(title) } +
      content
    end
  end

  def group(tag = :div, *args, **kwargs, &children)
    a_class = kwargs.delete(:class)

    # render the children & tag
    f_class = "#{a_class} Form-group"
    content = @template.capture(&children)

    @template.content_tag(tag, *args, class: f_class, **kwargs) do
      content
    end
  end

  def field(name, title = nil, *args, **kwargs, &children)
    a_class = kwargs.delete(:class)

    # check for field errors
    has_errors =
      object.respond_to?(:errors) &&
      object.errors.is_a?(ActiveModel::Errors) &&
      object.errors[name].present?

    errors = nil
    if has_errors
      errors = object.errors[name].join(",")
    end

    # render the children & tag
    f_class = "#{a_class} FormField #{has_errors ? "is-error" : ""}"
    content = @template.capture(&children)

    label(name, *args, class: f_class, **kwargs) do
      hint = @template.tag.p(class: "FormField-hint") do
        hint_text = @template.tag.span(title || name.to_s.titlecase)
        hint_error = has_errors ? @template.tag.span(" #{errors}", class: "FormField-errors") : ""
        hint_text + hint_error
      end

      hint + content
    end
  end
end
