module ApplicationHelper
  # -- elements --
  def filter_for(id, is_selected: false, is_error: false)
    link_to(id.to_s.titlecase, "##{id}",
      class: cx("Filter", is_selected: is_selected, is_error: is_error),
      data: { turbolinks: false }
    )
  end

  # -- queries --
  def errors?(*models)
    models.any? do |model|
      model.errors.present?
    end
  end

  # -- utilities --
  def cx(*classes, **states)
    active_classes = classes.dup

    states.each do |key, is_active|
      if is_active
        active_classes << key.to_s.dasherize
      end
    end

    active_classes.join(" ")
  end
end
