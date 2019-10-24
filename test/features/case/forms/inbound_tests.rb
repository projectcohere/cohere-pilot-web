require "test_helper"

class Case
  module Forms
    class InboundTests < ActiveSupport::TestCase
      test "can be initialized from a case" do
        kase = Case::from_record(cases(:opened_1))

        form = Inbound.new(kase)
        assert_present(form.first_name)
        assert_present(form.phone_number)
        assert_present(form.street)
        assert_present(form.account_number)
      end

      test "saves an inbound case" do
        form = Inbound.new(nil,
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
          form.save(
            suppliers(:supplier_1).id,
            enrollers(:enroller_1).id
          )
        end

        assert_difference(
          -> { Case::Record.count } => 1,
          -> { Recipient::Record.count } => 1,
          -> { Recipient::Account::Record.count } => 1,
        ) do
          did_save = act.()
          assert(did_save)
        end
      end

      test "does not save an invalid inbound case" do
        form = Inbound.new(nil,
          first_name: "Janice"
        )

        did_save = form.save(
          suppliers(:supplier_1).id,
          enrollers(:enroller_1).id
        )

        assert_not(did_save)
        assert_present(form.errors)
      end
    end
  end
end
