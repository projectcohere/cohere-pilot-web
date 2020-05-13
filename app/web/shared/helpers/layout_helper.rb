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
    def filter_for(id, selected: false, active: false)
      return link_to("##{id}",
        class: cx(
          "Filters-option",
          "is-selected" => selected,
          "is-active" => active,
        ),
        data: { turbolinks: false }
      ) do
        tag.span(id.to_s.titlecase, class: "Filters-text")
      end
    end

    def filter_panel_tag(id, visible: false, &children)
      return tag.section(
        id: id,
        class: cx(
          "Panel-tab",
          "is-visible" => visible,
        ),
        &children
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
    def section_tag(title = nil, *args, **kwargs, &children)
      a_class = kwargs.delete(:class)

      # pre-render children
      section_content = capture(&children)

      # render section tag
      section_class = cx(a_class, "Panel-section PanelSection")

      tag.div(*args, class: section_class, **kwargs) do
        section_header = "".html_safe

        if title.present?
          section_header = tag.div(class: "PanelSection-header") do
            tag.h1(title)
          end
        end

        section_header + section_content
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
