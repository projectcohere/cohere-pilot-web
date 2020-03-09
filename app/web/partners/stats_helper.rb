module Partners
  module StatsHelper
    # -- impls --
    # -- impls/pie-chart
    module Pie
      # the pie radius
      R = 10
      # the pie diameter
      D = R * 2
      # the pie slice radius
      R_2 = R / 2
      # the pie slice circumfrence
      C_2 = R * Math::PI
      # the font-size of the label
      L_H = 1.5
    end

    def pie_chart_tag(**kwargs, &children)
      a_class = kwargs.delete(:class)

      # pre-render slices
      slice_tags = capture(&children)

      # render pie with background
      return tag.svg(class: cx(a_class, "PieChart"), viewBox: "0 0 #{Pie::D} #{Pie::D}", **kwargs) do
        tag.circle(class: "PieChart-background", r: Pie::R, cx: Pie::R, cy: Pie::R) +
        slice_tags
      end
    end

    def pie_slice_tag(ratio, offset:, label:)
      # orient pie so 0 is the vertical
      offset -= 0.25

      # render slice
      slice_d = "
        M #{point(offset)}
        A #{point(0, r: 0)}, 0, #{ratio >= 0.5 ? 1 : 0}, 1, #{point((offset + ratio))}
        L #{point(0, r: 0)}
      "

      slice_tag = tag.path(
        class: "PieChart-slice",
        d: slice_d.strip,
      )

      # render text
      hover_tag = tag.text(
        label,
        class: "PieChart-hover",
        **point((offset + ratio / 2), r: Pie::R_2, dy: 0.8).to_h,
        "font-size": 0.8,
      )

      label_tag = tag.text(
        "#{(ratio * 100).round}%",
        class: "PieChart-label",
        **point((offset + ratio / 2), r: Pie::R_2, dy: -0.8).to_h,
        "font-size": Pie::L_H,
      )

      return slice_tag + hover_tag + label_tag
    end

    # -- impls/pie-chart/helpers
    class Point < ::Value
      # -- props --
      prop(:x)
      prop(:y)

      # -- queries --
      def to_s
        return "#{x} #{y}"
      end

      def to_h
        return { x: x, y: y }
      end
    end

    private def point(ratio, r: Pie::R, dy: 0)
      angle = ratio * Math::PI * 2
      return Point.new(
        x: (Pie::R + r * Math.cos(angle)).round(2),
        y: (Pie::R + r * Math.sin(angle)).round(2) + dy,
      )
    end

    # -- impls/bar-chart
    def bar_chart_tag(**kwargs, &children)
      a_class = kwargs.delete(:class)
      return tag.div(class: cx(a_class, "BarChart"), **kwargs, &children)
    end

    def bar_tag(value, ratio, label:)
      bar_tag = tag.div(
        class: "BarChart-bar",
        style: "height: #{(ratio * 100).round(2)}%;"
      )

      label_tag = tag.label(class: "BarChart-label") do
        tag.p(value, class: "BarChart-value") +
        tag.p(label, class: "BarChart-filter")
      end

      bar_tag + label_tag
    end
  end
end
