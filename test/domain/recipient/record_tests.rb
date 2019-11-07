require "test_helper"

class Recipient
  class RecordTests < ActiveSupport::TestCase
    test "santizies the phone number" do
      record = Record.new(phone_number: "(822) 101-2049")
      record.validate
      assert_equal(record.phone_number, "+18221012049")
    end
  end
end
