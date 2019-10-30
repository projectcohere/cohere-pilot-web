require "test_helper"
require "minitest/mock"

class Message
  class ReceiveFromRecipientTests < ActiveSupport::TestCase
    test "adds message attachments to a recipient's documents" do
      recipient = Recipient.new(
        id: nil,
        name: nil,
        phone_number: nil,
        address: nil,
        account: nil,
      )

      message = Message.new(
        sender: Sender.new(
          phone_number: "111-222-3333"
        ),
        attachments: [
          Attachment.new(
            url: "https://website.com/image.jpg"
          )
        ]
      )

      recipients = Minitest::Mock.new
        .expect(:find_one_by_phone_number, recipient, ["111-222-3333"])
        .expect(:save_new_documents, nil, [recipient])

      receive_message = ReceiveFromRecipient.new(
        decode: ->(_) { message },
        recipients: recipients
      )

      receive_message.("ignored-data")
      assert_equal(receive_message.recipient, recipient)
      assert_length(recipient.documents, 1)
      assert_equal(recipient.documents[0].source_url, "https://website.com/image.jpg")
    end

    test "raises an error if the recipient is missing" do
      message = Message.new(
        sender: Sender.new(
          phone_number: "111-222-3333"
        ),
        attachments: [
          Attachment.new(
            url: "https://website.com/image.jpg"
          )
        ]
      )

      recipients = Minitest::Mock.new
        .expect(:find_one_by_phone_number, nil, ["111-222-3333"])

      receive_message = ReceiveFromRecipient.new(
        decode: ->(_) { message },
        recipients: recipients
      )

      act = -> do
        receive_message.("ignored-data")
      end

      assert_raises(&act)
    end
  end
end
