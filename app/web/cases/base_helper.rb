module Cases
  module BaseHelper
    include Logging
    include Case::Policy::Context::Shared

    # -- search --
    def cases_search_params
      return request.query_parameters
    end

    def cases_search_path(params = nil)
      if params == nil
        return request.path
      end

      uri = URI.parse(request.fullpath)
      uri.query = cases_search_params.merge(params).to_query

      return uri.to_s
    end

    # -- filters --
    def cases_scope_link_to(scope)
      return link_to(scope.name, cases_search_path(scope: scope.key),
        id: "filter-#{scope.key}",
        class: cx(
          "Filters-option",
          "is-selected": @scope == scope,
        ),
      )
    end

    # -- cells --
    def case_cell_options(view, shows_status: true, shows_activity: false)
      return {
        id: "case-#{view.id}",
        class: cx(
          "CaseCell",
          "CaseCell-#{view.status}" => shows_status == true || shows_status == view.status,
          "is-active" => shows_activity && view.new_activity?,
        )
      }
    end

    # -- chat --
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

    def chat_macros_json(groups)
      log.debug { "#{self.class.name}:#{__LINE__} macros -- #{groups}"}

      # transform groups into flat list of macros
      data = groups.flat_map(&:list).map do |m|
        next {
          body: m.body,
          attachment: m.file&.then { |f|
            url = url_for(f.representation(resize: "400x400>"))
            next {
              id: f.id,
              preview: {
                name: f.filename.to_s,
                url: url,
                preview_url: url,
              },
            }
          },
        }
      end

      return data.to_json
    end

    def chat_macros_options(groups)
      i = 0

      options = groups.map do |g|
        next [
          g.name,
          g.list.map { |m|
            o = [m.name, i]
            i += 1
            next o
          }
        ]
      end

      return grouped_options_for_select(options)
    end
  end
end
