module ApplicationHelper
  private def cx(*classes, states)
    classes += states.is_a?(Hash) ? states.filter { |_, v| v }.keys : states
    classes.join(" ")
  end
end
