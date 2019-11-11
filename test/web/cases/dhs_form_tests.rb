require "test_helper"
require "minitest/mock"

module Cases
  class DhsFormTests < ActiveSupport::TestCase
    test "can be initialized from a case" do
      kase = Case::Repo.map_record(cases(:pending_1))

      form = DhsForm.new(kase)
      assert_present(form.dhs_number)
      assert_present(form.income)
    end

    test "can be initialized from params" do
      kase = Case::Repo.map_record(cases(:opened_1))

      form_attrs = {
        "dhs_number" => "11111",
        "household_size" => "5",
        "income" => "$111"
      }

      form = DhsForm.new(
        kase,
        form_attrs,
      )

      assert_equal(form.dhs_number, "11111")
      assert_equal(form.household_size, "5")
      assert_equal(form.income, "111")
    end

    test "saves household updates" do
      kase = Case::Repo.map_record(cases(:opened_1))
      case_repo = Minitest::Mock.new
      case_repo.expect(:save_dhs_account, nil, [kase])

      form_attrs = {
        "dhs_number" => "11111",
        "household_size" => "3",
        "income" => "$999"
      }

      form = DhsForm.new(
        kase,
        form_attrs,
        case_repo: case_repo
      )

      did_save = form.save
      assert(did_save)
    end

    test "sanitizes income" do
      kase = Case::Repo.map_record(cases(:opened_1))
      form = DhsForm.new(kase, {
        "income" => "A$100.00"
      })

      assert_equal(form.income, "100.00")
    end

    test "has an address" do
      kase = Case::Repo.map_record(cases(:opened_1))
      form = DhsForm.new(kase)
      assert_length(form.address, 3)
    end
  end
end
