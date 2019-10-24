require "test_helper"

class Case
  module Forms
    class OpenedTests < ActiveSupport::TestCase
      test "stubs an income history" do
        kase = Case::from_record(cases(:opened_1))
        form = Opened.new(kase)
        assert_length(form.income_history, 1)
      end

      test "can be initialized from a case" do
        kase = Case::from_record(cases(:scorable_1))

        form = Opened.new(kase)
        assert_present(form.dhs_number)
        assert_present(form.income_history)
        assert_present(form.income_history[0].amount)
      end

      test "can be initialized from params" do
        kase = Case::from_record(cases(:opened_1))
        case_params = {
          dhs_number: "11111",
          household_size: "5",
          income_history: {
            "0": {
              month: "10/19",
              amount: "$111"
            }
          }
        }

        form = Opened.new(kase, case_params)
        assert_length(form.income_history, 1)

        income = form.income_history[0]
        assert_equal(income.month, "10/19")
        assert_equal(income.amount, "$111")
      end

      test "saves household updates" do
        kase = Case.from_record(cases(:opened_1))
        form = Opened.new(kase,
          dhs_number: "11111",
          household_size: "3",
          income_history: {
            "0": {
              month: "10/19",
              amount: "$999",
            },
            "1": {
              month: "11/19",
              amount: "$540"
            }
          }
        )

        did_save = form.save
        assert(did_save)

        record = kase.record
        assert_equal(record.status.to_sym, :scorable)

        record = kase.recipient.record
        assert_equal(record.dhs_number, "11111")
        assert_present(record.household)
        assert_equal(record.household.size, "3")
        assert_length(record.household.income_history, 2)
      end

      test "does not save invalid household updates" do
        kase = Case.from_record(cases(:opened_1))
        form = Opened.new(kase,
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

      test "provides the address" do
        kase = Case.from_record(cases(:opened_1))
        form = Opened.new(kase)
        assert_length(form.address, 3)
      end
    end
  end
end
