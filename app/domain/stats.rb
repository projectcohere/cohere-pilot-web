class Stats < ::Value
  # -- props --
  prop(:cases)
  prop(:durations)

  # -- queries --
  def min_minutes_to_enroll
    return @cases.map(&:minutes_to_enroll).min
  end

  def avg_minutes_to_enroll
    sorted = @cases.map(&:minutes_to_enroll).sort
    length = sorted.length
    median = (sorted[(length - 1) / 2] + sorted[length / 2]) / 2.0
    return median.round
  end

  def percent_approved
    approved = @cases.count(&:approved?).to_f
    return ((approved / @cases.count) * 100).round
  end

  def cases_by_supplier
    quantities = @cases
      .group_by(&:supplier)
      .map { |s, cs| Quantity.new(filter: s, count: cs.count, total: @cases.count) }

    return quantities.sort
  end
end
