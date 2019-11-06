require "test_helper"
require "minitest/mock"

class Case
  module Forms
    class InboundTests < ActiveSupport::TestCase
      test "can be initialized from a case" do
        kase = Case::Repo.map_record(cases(:opened_1))

        form = Inbound.new(kase)
        assert_present(form.first_name)
        assert_present(form.phone_number)
        assert_present(form.street)
        assert_present(form.account_number)
      end

      test "saves an inbound case" do
        cases = Minitest::Mock.new
          .expect(
            :save_opened, nil, [Case]
          )

        enrollers = Minitest::Mock.new
          .expect(
            :find_default,
            Enroller.new(id: "enroller-id", name: nil)
          )

        suppliers = Minitest::Mock.new
          .expect(
            :find_one,
            Supplier.new(id: "supplier-id", name: nil),
            [13]
          )

        form_params = {
          "first_name" => "Janice",
          "last_name" => "Sample",
          "phone_number" => Faker::PhoneNumber.phone_number,
          "street" => "123 Test Street",
          "city" => "Testopolis",
          "state" => "Testissippi",
          "zip" => "11111",
          "account_number" => "22222",
          "arrears" => "$1000.0"
        }

        form = Inbound.new(
          nil,
          13,
          form_params,
          cases: cases,
          suppliers: suppliers,
          enrollers: enrollers
        )

        did_save = form.save
        assert(did_save)
      end

      test "does not save an invalid inbound case" do
        form = Inbound.new(nil, nil, {
          "first_name" => "Janice"
        })

        did_save = form.save
        assert_not(did_save)
        assert_present(form.errors)
      end
    end
  end
end
