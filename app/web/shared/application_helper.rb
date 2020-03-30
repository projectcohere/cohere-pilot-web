module ApplicationHelper
  include Pagy::Frontend

  # -- elements --
  def totals_for(page, of:)
    name = of
    if page == nil || page.count == 0
      return ""
    end

    return tag.h2(
      "#{page.items} of #{page.count} #{name}",
      class: "Main-totals"
    )
  end

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

  # -- elements/layout
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

  # -- elements/chat
  def chat_message_tag(chat_message, sender, receiver, &children)
    # pre-render children
    message_content = capture(&children)

    # determine tag props
    is_sent = chat_message.sent_by?(sender)
    classes = cx("ChatMessage",
      "ChatMessage--sent" => is_sent,
      "ChatMessage--received" => !is_sent,
    )

    sender_name = is_sent ? "Me" : receiver

    # render tag
    tag.li(class: classes) do
      sender_tag = tag.label(sender_name, class: "ChatMessage-sender")
      sender_tag + message_content
    end
  end

  # -- elements/pager
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
