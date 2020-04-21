module Helpers
  module NavigationHelper
    # -- helpers --
    def navigation_icon_tag(key, name, width: 36)
      return tag.span(
        class: "NavigationIcon is-#{key}",
        alt: "#{name} Icon",
        width: width,
        height: 36,
      )
    end

    def navigation_link_tag_tags
      links = []

      if policy.permit?(:list_queue)
        links.push(Link.new(
          key: :queue,
          name: "Queue",
          path: queue_cases_path
        ))
      end

      if policy.permit?(:list)
        links.push(Link.new(
          key: :cases,
          name: "Cases",
          path: cases_path
        ))
      end

      links.find.each do |r|
        if request.path.starts_with?(r.path)
          r.active!
          break
        end
      end

      return raw(links.map { |r| navigation_link_tag(r) }.join)
    end

    def navigation_link_tag(link)
      return link_to(link.path,
        class: cx(
          "Navigation-link",
          "is-active": link.active?,
        ),
      ) do
        navigation_icon_tag(link.key, link.name) +
        tag.span(link.name, class: "Navigation-linkName")
      end
    end

    # -- types --
    class Link < ::Value
      # -- props --
      prop(:key)
      prop(:name)
      prop(:path)
      prop(:active, default: false, predicate: true)

      # -- queries --
      def active!
        @active = true
      end
    end

  end
end
