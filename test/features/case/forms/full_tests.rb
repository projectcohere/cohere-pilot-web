require "test_helper"

class Case
  module Forms
    class FullTests < ActiveSupport::TestCase
      test "can be initialized from a case" do
        kase = Case::from_record(cases(:scorable_1))

        form = Full.new(kase)
        assert_present(form.dhs_number)
        assert_present(form.first_name)
        assert_present(form.phone_number)
        assert_present(form.street)
        assert_present(form.account_number)
        assert_present(form.dhs_number)
        assert_present(form.income_history)
        assert_present(form.income_history[0].amount)
      end

      test "saves a case" do
        kase = Case::from_record(cases(:scorable_1))
        form = Full.new(kase)
        form.first_name = "Edith"

        did_save = form.save
        assert(did_save)

        record = kase.recipient.record
        assert_equal(record.first_name, "Edith")
      end

      test "does not save an invalid case" do
        kase = Case::from_record(cases(:scorable_1))
        form = Full.new(kase)
        form.first_name = ""

        did_save = form.save
        assert_not(did_save)
        assert_present(form.errors[:first_name])
      end
    end
  end
end
