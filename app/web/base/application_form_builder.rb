class ApplicationFormBuilder < ::ActionView::Helpers::FormBuilder
  def fieldset(title, *args, **kwargs, &children)
    a_class = kwargs.delete(:class)
    @template.tag.div(*args, class: "#{a_class} Form-fieldset", **kwargs) do
      @template.tag.h2(title) +
      children.()
    end
  end

  def field(name, title = nil, *args, **kwargs, &children)
    a_class = kwargs.delete(:class)
    label(name, *args, class: "#{a_class} Field", **kwargs) do
      @template.tag.p(title || name.to_s.titlecase, class: "Field-hint") +
      children.(name)
    end
  end
end
