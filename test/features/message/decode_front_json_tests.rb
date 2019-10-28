require "test_helper"

class Message
  class DecodeFrontJsonTests < ActiveSupport::TestCase
    test "can be decoded from front json" do
      decode = DecodeFrontJson.new
      message_json = file_fixture("front/messages/inbound.json").read
      message = decode.(message_json)
      assert_equal(message.recipient.phone_number, "+12223334444")
    end
  end
end
