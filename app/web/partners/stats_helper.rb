module Partners
  module StatsHelper
    # -- impls --
    # -- impls/elements
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

    def pie_tag(&children)
      # pre-render slices
      slice_tags = capture(&children)

      # render pie with background
      return tag.svg(class: "Pie", viewBox: "0 0 #{Pie::D} #{Pie::D}") do
        tag.circle(class: "Pie-background", r: Pie::R, cx: Pie::R, cy: Pie::R) +
        slice_tags
      end
    end

    def pie_slice_tag(percent, offset:, label:)
      slice_tag = tag.circle(
        class: "Pie-slice",
        r: Pie::R_2, cx: Pie::R, cy: Pie::R,
        "stroke-width": Pie::R,
        "stroke-dasharray": "#{percent * Pie::C_2} #{Pie::C_2}",
        transform: "rotate(#{offset * 360} #{Pie::R} #{Pie::R})",
      )

      label_a = (offset + percent / 2) * 2 * Math::PI
      label_tag = tag.text(
        label,
        class: "Pie-label",
        x: Pie::R + Pie::R * Math.cos(label_a),
        y: Pie::R + Pie::R * Math.sin(label_a) + Pie::L_H * 0.5,
        "font-size": Pie::L_H,
      )

      return slice_tag + label_tag
    end
  end
end
