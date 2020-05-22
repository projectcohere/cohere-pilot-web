require "test_helper"

class MoneyTests < ActiveSupport::TestCase
  # -- queries --
  test "format money as a dollar amount" do
    money = Money.cents(644_40)
    assert_equal(money.dollars, "644.40")
  end

  # -- factories --
  test "create money from a cents amount" do
    money = Money.cents(500)
    assert_equal(money.cents, 500)
  end

  test "create money from a nil cents amount" do
    money = Money.cents(nil)
    assert_nil(money)
  end

  test "create money from a dollar amount" do
    money = Money.dollars("644.17")
    assert_equal(money.cents, 644_17)
  end

  test "create money from a dollar amount missing digits" do
    money = Money.dollars("644.2")
    assert_equal(money.cents, 644_20)
  end

  test "create money from an empty dollar amount" do
    money = Money.dollars("")
    assert_nil(money)
  end
end
