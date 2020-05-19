require "test_helper"

class MoneyTests < ActiveSupport::TestCase
  # -- queries --
  test "format money as a dollar amount" do
    money = Money.cents(64440)
    assert_equal(money.dollars, "644.40")
  end

  # -- factories --
  test "create money from a dollar amount" do
    money = Money.dollars("644.17")
    assert_equal(money.cents, 64417)
  end

  test "create money from a dollar amount missing digits" do
    money = Money.dollars("644.2")
    assert_equal(money.cents, 64420)
  end
end
