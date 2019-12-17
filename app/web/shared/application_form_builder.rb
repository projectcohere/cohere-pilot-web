class ApplicationFormBuilder < ::ActionView::Helpers::FormBuilder
  def field(name, title = nil, *args, prefix: nil, disabled: false, bare: false, background: true, **kwargs, &children)
    a_class = kwargs.delete(:class)

    # check for field errors
    has_errors =
      object.respond_to?(:errors) &&
      object.errors.is_a?(ActiveModel::Errors) &&
      object.errors[name].present?

    errors = if has_errors
      object.errors[name].join(",")
    end

    # pre-render children
    field_content = @template.capture(&children)

    # render the children & tag
    field_class = @template.cx(a_class, "Field--input Field--fixed",
      "is-disabled" => disabled
    )

    @template.field_tag(name, *args, errors: errors, class: field_class, **kwargs) do
      if prefix.nil?
        field_content
      else
        @template.tag.span(prefix, class: "Field-prefix") + field_content
      end
    end
  end
end
