module ApplicationHelper
  include Helpers::LayoutHelper
  include Helpers::NavigationHelper

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
