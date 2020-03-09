require "test_helper"

class StatsTest < ActiveSupport::TestCase
  test "finds the min time to enroll" do
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

    assert_equal(stats.min_minutes_to_enroll, 10)
  end

  test "finds the avg time to enroll" do
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

    assert_equal(stats.avg_minutes_to_enroll, 15)
  end

  test "finds the percent approved" do
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

    assert_equal(stats.percent_approved, 67)
  end

  test "finds cases by supplier" do
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

    assert_equal(stats.cases_by_supplier, [
      Stats::Quantity.stub(filter: supplier_1, count: 1),
      Stats::Quantity.stub(filter: supplier_2, count: 2),
    ])
  end
end
