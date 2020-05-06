require "test_helper"

module Recipient
  class HouseholdTests < ActiveSupport::TestCase
    test "has an fpl percent given size and income" do
      household = Recipient::Household.stub(
        size: 5,
        income: Money.cents(2493_33),
      )

      assert_equal(household.fpl_percent, 100)
    end

    test "has no fpl percentage without size and income" do
      household = Recipient::Household.stub(
        size: nil,
        income: Money.cents(2493_33),
      )

      assert_nil(household.fpl_percent)
    end
  end
end
