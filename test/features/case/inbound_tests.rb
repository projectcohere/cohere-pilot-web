require "test_helper"

class Case
  class InboundTests < ActiveSupport::TestCase
    test "saves an inbound case" do
      inbound = Case::Forms::Inbound.new(
        first_name: "Janice",
        last_name: "Sample",
        phone_number: "111-222-3333",
        street: "123 Test Street",
        city: "Testopolis",
        state: "Testissippi",
        zip: "11111",
        account_number: "22222",
        arrears: "$1000.0"
      )

      act = -> do
        inbound.save(
          suppliers(:supplier_1).id,
          enrollers(:enroller_1).id
        )
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

    test "does not save an invalid inbound case" do
      inbound = Case::Forms::Inbound.new(
        first_name: "Janice"
      )

      did_save = inbound.save(
        suppliers(:supplier_1).id,
        enrollers(:enroller_1).id
      )

      assert_not(did_save)
      assert(inbound.errors.count != 0)
    end
  end
end
