require "test_helper"

class Message
  class DecodeFrontJsonTests < ActiveSupport::TestCase
    test "decodes a message from front json" do
      data = file_fixture("front/messages/inbound.json").read
      decode = DecodeFrontJson.new

      message = decode.(data)
      assert_equal(message.sender.phone_number, "+12223334444")
      assert_length(message.attachments, 1)
      assert_equal(message.attachments[0].url, "https://website.com/image.jpg")
    end
  end
end
