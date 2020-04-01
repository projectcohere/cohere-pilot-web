require "test_helper"

module Front
  class DecodeMessageTests < ActiveSupport::TestCase
    test "decodes a message from front json" do
      data = file_fixture("front/messages/inbound.json").read
      decode = DecodeMessage.new

      message = decode.(data)
      assert_equal(message.phone_number, "2223334444")
      assert_length(message.attachments, 1)
      assert_equal(message.attachments[0].url, "https://website.com/image.jpg")
    end
  end
end
