require 'test_helper'

class Recipient
  class NameTests < ActiveSupport::TestCase
    test "it formats the name" do
      address = Name.new(first: "Janice", last: "Sample")
      assert_equal(address.to_s, "Janice Sample")
    end
  end
end
