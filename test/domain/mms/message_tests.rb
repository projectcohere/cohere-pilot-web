module Mms
  class MessageTests < ActiveSupport::TestCase
    # -- queries --
    test "it finds a recipient phone number for a sent message" do
      message = Mms::Message.stub(
        sender_phone_number: "1112223333",
        receiver_phone_number: :receiver,
      )

      assert_equal(message.recipient_phone_number, "1112223333")
    end

    test "it finds a recipient phone number for a received message" do
      message = Mms::Message.stub(
        sender_phone_number: ENV["FRONT_API_PHONE_NUMBER"],
        receiver_phone_number: "1112223333",
      )

      assert_equal(message.recipient_phone_number, "1112223333")
    end
  end
end
