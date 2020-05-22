module Helpers
  module NavigationHelper
    # -- helpers --
    def navigation_link_tags
      links = []

      if permit?(:list_cases)
        links.push(Link.new(:cases, cases_path))
      end

      if permit?(:list_queue)
        links.push(Link.new(:queue, queue_cases_path))
      end

      if permit?(:list_search)
        links.push(Link.new(:search, search_cases_path))
      end

      if permit?(:list_reports)
        links.push(Link.new(:reports, new_report_path))
      end

      if permit?(:admin)
        links.push(Link.new(:admin, admin_path))
      end

      links.reverse.each do |r|
        if request.path.starts_with?(r.path)
          r.active!
          break
        end
      end

      return raw(links.map { |r| navigation_link_tag(r) }.join)
    end

    def navigation_link_tag(link)
      name = t(".#{link.key}")

      return link_to(link.path,
        class: cx(
          "Navigation-link",
          "is-active": link.active?,
        ),
        tid: "#{name} Page Link",
      ) do
        next (
          navigation_icon_tag(link.key, name) +
          tag.span(name, class: "Navigation-linkName")
        )
      end
    end

    def navigation_icon_tag(key, name, width: 36)
      return tag.span(
        class: "Navigation-icon Icon Icon--#{key}",
        alt: "#{name} Icon",
        width: width,
        height: 36,
      )
    end

    # -- types --
    Link = Struct.new(:key, :path) do
      def active!
        @active = true
      end

      def active?
        return @active
      end
    end
  end
end
