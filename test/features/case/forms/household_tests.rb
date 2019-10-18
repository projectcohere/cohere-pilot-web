require "test_helper"

class Case
  module Forms
    class HouseholdTests < ActiveSupport::TestCase
      test "stubs an income history" do
        kase = cases(:incomplete_1)
        form = Household.new(kase)
        assert_length(form.income_history, 1)
      end

      test "can be initialized from params" do
        kase = cases(:incomplete_1)
        params = {
          mdhhs_number: "11111",
          household_size: "5",
          income_history: {
            "0": {
              month: "10/19",
              amount: "$111"
            },
            "1": {
              month: "09/19",
              amount: "$222"
            }
          }
        }

        form = Household.new(kase, params)
        assert_length(form.income_history, 2)

        income = form.income_history[0]
        assert_equal(income.month, "10/19")
        assert_equal(income.amount, "$111")
      end

      test "saves household updates" do
        skip

        form = Household.new(
          income_history: {
            "0": {
              month: "10/19",
              amount: "$999",
            }
          }
        )

        act = -> do
          form.save
        end

        expected_change = 1
        assert_difference([
          -> { Case::Record.count },
          -> { Recipient::Record.count },
          -> { Recipient::Account::Record.count },
        ], expected_change) do
          did_save = act.()
          assert(did_save)
        end
      end

      test "does not save invalid household updates" do
        form = Household.new(
          income_history: {
            "0": {
              month: "10/19",
            }
          }
        )

        did_save = form.save
        assert_not(did_save)
        assert_present(form.errors)
        assert_present(form.errors[:income_history])
        assert_present(form.income_history[0].errors)
      end
    end
  end
end
