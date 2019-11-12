class ApplicationFormBuilder < ::ActionView::Helpers::FormBuilder
  def section(title = nil, header_tag = :h2, *args, **kwargs, &children)
    a_class = kwargs.delete(:class)

    # render the children & tag
    f_class = "#{a_class} Form-section"
    content = @template.capture(&children)

    @template.tag.section(*args, class: f_class, **kwargs) do
      section_title = "".html_safe

      if title.present?
        section_title = @template.tag.h1 do
          @template.tag.span(title)
        end
      end

      section_title + content
    end
  end

  def field(name, title = nil, *args, prefix: nil, background: true, **kwargs, &children)
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
    content = @template.capture(&children)

    field_class = if has_errors
      "#{a_class} FormField is-error"
    else
      "#{a_class} FormField"
    end

    label(name, *args, class: field_class, **kwargs) do
      hint = @template.tag.p(class: "FormField-hint") do
        hint_text = @template.tag.span(title || name.to_s.titlecase)
        hint_error = has_errors ? @template.tag.span(" #{errors}", class: "FormField-errors") : ""
        hint_text + hint_error
      end

      input_content = if prefix.nil?
        content
      else
        @template.tag.span(prefix, class: "FormField-prefix") + content
      end

      input_class = if background
        "FormField-input--background"
      else
        "FormField-input"
      end

      hint + @template.tag.div(input_content, class: input_class)
    end
  end

  def value(val, *args, fallback: nil, **kwargs)
    # add fallback if necessary
    value_class = if val.nil?
      "FormField-value is-missing"
    else
      "FormField-value"
    end

    @template.tag.p(val || fallback, class: value_class)
  end
end
