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
    end
  end
end
