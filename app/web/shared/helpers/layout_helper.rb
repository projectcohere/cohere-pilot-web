module Helpers
  module LayoutHelper
    def layout_tag(&children)
      m = user_membership

      return tag.body(
        class: cx(
          "Layout",
          "Layout--#{m}" => m != nil,
        ),
        &children
      )
    end
  end
end
