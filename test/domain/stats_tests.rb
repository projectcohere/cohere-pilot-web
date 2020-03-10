require "test_helper"

class StatsTest < ActiveSupport::TestCase
  test "finds the min time to determination" do
    stats = Stats.stub(
      cases: [
        Stats::Case.stub(
          created_at: 15.minutes.ago,
          completed_at: 0.minutes.ago
        ),
        Stats::Case.stub(
          created_at: 10.minutes.ago,
          completed_at: 0.minutes.ago
        ),
      ],
    )

    assert_equal(stats.min_minutes_to_determination, 10)
  end

  test "finds the avg time to determination" do
    stats = Stats.stub(
      cases: [
        Stats::Case.stub(
          created_at: 16.minutes.ago,
          completed_at: 0.minutes.ago
        ),
        Stats::Case.stub(
          created_at: 10.minutes.ago,
          completed_at: 0.minutes.ago
        ),
        Stats::Case.stub(
          created_at: 13.minutes.ago,
          completed_at: 0.minutes.ago
        ),
        Stats::Case.stub(
          created_at: 18.minutes.ago,
          completed_at: 0.minutes.ago
        ),
      ],
    )

    assert_equal(stats.avg_minutes_to_determination, 15)
  end

  test "finds the percent enrolled" do
    stats = Stats.stub(
      cases: [
        Stats::Case.stub(
          status: ::Case::Status::Approved,
        ),
        Stats::Case.stub(
          status: ::Case::Status::Denied,
        ),
        Stats::Case.stub(
          status: ::Case::Status::Approved,
        ),
      ]
    )

    assert_equal(stats.percent_enrolled, 67)
  end

  test "finds the percent same day determinations" do
    stats_tz = Stats::Case::LocalTimeZone.utc_offset.seconds

    stats = Stats.stub(
      cases: [
        Stats::Case.stub(
          created_at: Time.zone.local(2018, 02, 15) - stats_tz,
          completed_at: Time.zone.local(2018, 02, 15) - stats_tz + 15.minutes,
        ),
        Stats::Case.stub(
          created_at: Time.zone.local(2018, 02, 15) - stats_tz,
          completed_at: Time.zone.local(2018, 02, 16) - stats_tz,
        ),
        Stats::Case.stub(
          created_at: Time.zone.local(2018, 02, 15) - stats_tz,
          completed_at: Time.zone.local(2018, 02, 16) - stats_tz - 1.second,
        ),
      ]
    )

    assert_equal(stats.percent_same_day_determinations, 67)
  end

  test "finds the number cases by supplier" do
    supplier_1 = Stats::Supplier.stub(
      id: 1
    )

    supplier_2 = Stats::Supplier.stub(
      id: 2
    )

    stats = Stats.stub(
      cases: [
        Stats::Case.stub(supplier: supplier_2),
        Stats::Case.stub(supplier: supplier_1),
        Stats::Case.stub(supplier: supplier_2),
      ]
    )

    assert_equal(stats.num_cases_by_supplier, [
      Stats::Quantity.stub(filter: supplier_1, count: 1),
      Stats::Quantity.stub(filter: supplier_2, count: 2),
    ])
  end

  test "finds the avg time per case by partner" do
    stats = Stats.stub(
      durations: Stats::Durations.stub(
        dhs: Stats::Duration.stub(avg_seconds: 3 * 60),
        enroller: Stats::Duration.stub(avg_seconds: 6 * 60),
        recipient: Stats::Duration.stub(avg_seconds: 8 * 60),
      )
    )

    assert_equal(stats.avg_minutes_by_partner, [
      Stats::Quantity.stub(filter: "MDHHS", count: 3),
      Stats::Quantity.stub(filter: "Wayne Metro", count: 6),
      Stats::Quantity.stub(filter: "Recipients", count: 8),
    ])
  end
end
