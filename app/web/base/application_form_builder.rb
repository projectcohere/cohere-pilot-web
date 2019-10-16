class ApplicationFormBuilder < ::ActionView::Helpers::FormBuilder
  def fieldset(title, *args, **kwargs, &children)
    a_class = kwargs.delete(:class)

    # render the children & tag
    f_class = "#{a_class} Form-fieldset"
    content = @template.capture(&children)

    @template.tag.div(*args, class: f_class, **kwargs) do
      @template.tag.h2(title) +
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
    f_class = "#{a_class} Field #{has_errors ? "is-error" : ""}"
    content = @template.capture(&children)

    label(name, *args, class: f_class, **kwargs) do
      hint = @template.tag.p(class: "Field-hint") do
        hint_text = @template.tag.span(title || name.to_s.titlecase)
        hint_error = has_errors ? @template.tag.span(" #{errors}", class: "Field-errors") : ""
        hint_text + hint_error
      end

      hint + content
    end
  end
end
