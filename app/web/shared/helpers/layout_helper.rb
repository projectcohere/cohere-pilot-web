module Helpers
  module LayoutHelper
    include Pagy::Frontend

    # -- root --
    def layout_tag(&children)
      role = user_role

      return tag.body(
        class: cx(
          "Layout",
          "Layout--#{role}" => role != nil,
        ),
        &children
      )
    end

    # -- filters --
    def filter_for(id, is_selected: false, is_error: false)
      link_to(id.to_s.titlecase, "##{id}",
        class: cx(
          "Filter",
          "is-selected" => is_selected,
          "is-active" => is_error
        ),
        data: { turbolinks: false }
      )
    end

    def errors?(*models)
      return models.any? { |m| m&.errors&.present? }
    end

    # -- links --
    def back_link_tag
      return link_to(
        t(".back"),
        "javascript:history.back()",
        class: "PageHeader-back"
      )
    end

    # -- lists --
    def pager_for(page, of:)
      name = of

      if page == nil || page.count == 0
        return ""
      end

      return tag.div(class: "Pager") do
        pager_nav = ""
        if page.pages > 1
          pager_nav = pagy_nav(page)
        end

        pager_total = tag.p(
          "#{page.from} to #{page.to} of #{page.count} #{name}",
          class: "Pager-total"
        )

        raw(pager_nav + pager_total)
      end
    end

    # -- panels --
    def section_tag(title = nil, header_tag = :h2, *args, **kwargs, &children)
      a_class = kwargs.delete(:class)

      # pre-render children
      section_content = capture(&children)

      # render section tag
      section_class = cx(a_class, "Panel-section")

      tag.div(*args, class: section_class, **kwargs) do
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
        title = title || name.to_s.titlecase

        hint_tag = title.blank? ? raw("") : tag.p(class: "Field-hint") do
          hint_text = tag.span(title || name.to_s.titlecase)
          hint_error = errors.present? ? tag.span(" #{errors}", class: "Field-errors") : ""
          hint_text + hint_error
        end

        hint_tag + tag.div(field_content, class: "Field-value")
      end
    end

    def field_value_tag(value, fallback: nil)
      if not value.nil?
        value
      elsif not fallback.nil?
        tag.span(fallback, class: "Field-fallback")
      end
    end
  end
end
