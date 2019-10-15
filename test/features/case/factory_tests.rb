require "test_helper"

class Case
  class FactoryTests < ActiveSupport::TestCase
    test "creates an inbound case" do
      factory = Case::Factory.new
      inbound = Case::Inbound.new(
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

      n_cases = Case::Record.count
      n_recipients = Recipient::Record.count
      n_accounts = Recipient::Account::Record.count

      factory.create_inbound(
        inbound,
        suppliers(:supplier_1).id,
        enrollers(:enroller_1).id
      )

      assert_equal(Case::Record.count, n_cases + 1)
      assert_equal(Recipient::Record.count, n_recipients + 1)
      assert_equal(Recipient::Account::Record.count, n_accounts + 1)
    end
  end
end
