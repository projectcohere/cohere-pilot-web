module Helpers
  module LayoutHelper
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
  end
end
