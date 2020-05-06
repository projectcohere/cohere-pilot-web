require "test_helper"

module Recipient
  class AddressTests < ActiveSupport::TestCase
    test "formats address as lines" do
      address = Address.new(
        street: "123 Sample St.",
        street2: "Apt. 2",
        city: "Detroit",
        state: "MI",
        zip: "48126"
      )

      assert_equal(address.lines, [
        "123 Sample St.",
        "Apt. 2",
        "Detroit, MI 48126"
      ])
    end
  end
end
