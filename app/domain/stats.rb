class Stats < ::Value
  # -- props --
  prop(:cases)
  prop(:durations)

  # -- queries --
  def min_minutes_to_determination
    return @cases.map(&:minutes_to_determination).min
  end

  def avg_minutes_to_determination
    sorted = @cases.map(&:minutes_to_determination).sort
    length = sorted.length
    median = (sorted[(length - 1) / 2] + sorted[length / 2]) / 2.0
    return median.round
  end

  def percent_enrolled
    approved = @cases.count(&:approved?).to_f
    return ((approved / @cases.count) * 100).round
  end

  def percent_same_day_determinations
    return 23
  end

  def num_cases_by_supplier
    quantities = @cases
      .group_by(&:supplier)
      .map { |s, cs| Quantity.new(filter: s, count: cs.count, total: @cases.count) }

    return quantities.sort
  end

  def avg_minutes_by_partner
    maximum = (@durations.max_avg_seconds / 60.0).round

    return [
      Quantity.new(
        filter: "MDHHS",
        count: (@durations.dhs.avg_seconds / 60.0).round,
        total: maximum,
      ),
      Quantity.new(
        filter: "Wayne Metro",
        count: (@durations.enroller.avg_seconds / 60.0).round,
        total: maximum,
      ),
      Quantity.new(
        filter: "Recipients",
        count: (@durations.recipient.avg_seconds / 60.0).round,
        total: maximum,
      ),
    ]
  end
end
