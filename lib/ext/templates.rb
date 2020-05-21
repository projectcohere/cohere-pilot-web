module Ext
  module Templates
    # -- constants
    TestIdAttribute = :tid

    # -- modules --
    module Tag
      def initialize(object_name, method_name, template_object, options = {})
        if Rails.env.production?
          options.delete(TestIdAttribute)
        end

        super
      end
    end

    module Select
      def initialize(object_name, method_name, template_object, choices, options, html_options)
        html_options[TestIdAttribute] = options.delete(TestIdAttribute)
        super
      end
    end

    # -- installation --
    T = ActionView::Helpers::Tags
    T::Base.prepend(Tag)
    T::Select.prepend(Select)
  end
end
