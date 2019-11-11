require "test_helper"
require "minitest/mock"

module Cases
  class SupplierFormTests < ActiveSupport::TestCase
    test "can be initialized from a case" do
      kase = Case::Repo.map_record(cases(:opened_1))

      form = SupplierForm.new(kase)
      assert_present(form.first_name)
      assert_present(form.phone_number)
      assert_present(form.street)
      assert_present(form.account_number)
    end

    test "saves an supplier case" do
      case_repo = Minitest::Mock.new
        .expect(
          :save_opened, nil, [Case]
        )

      enroller_repo = Minitest::Mock.new
        .expect(
          :find_default,
          Enroller.new(id: "enroller-id", name: nil)
        )

      supplier_repo = Minitest::Mock.new
        .expect(
          :find,
          Supplier.new(id: "supplier-id", name: nil),
          [13]
        )

      form_params = {
        "first_name" => "Janice",
        "last_name" => "Sample",
        "phone_number" => Faker::Number.number(digits: 10).to_s,
        "street" => "123 Test Street",
        "city" => "Testopolis",
        "state" => "Testissippi",
        "zip" => "11111",
        "account_number" => "22222",
        "arrears" => "$1000.0"
      }

      form = SupplierForm.new(
        nil,
        13,
        form_params,
        case_repo: case_repo,
        supplier_repo: supplier_repo,
        enroller_repo: enroller_repo
      )

      did_save = form.save
      assert(did_save)
    end

    test "does not save an invalid supplier case" do
      form = SupplierForm.new(nil, nil, {
        "first_name" => "Janice"
      })

      did_save = form.save
      assert_not(did_save)
      assert_present(form.errors)
    end

    test "sanitizes phone numbers" do
      form = SupplierForm.new(nil, nil, {
        "phone_number" => "+1 (213) 445-2820"
      })

      assert_equal(form.phone_number, "12134452820")
    end

    test "sanitizes arrears" do
      form = SupplierForm.new(nil, nil, {
        "arrears" => "A$100.00"
      })

      assert_equal(form.arrears, "100.00")
    end
  end
end
