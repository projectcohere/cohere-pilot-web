require "test_helper"

class RecipientTests < ActiveSupport::TestCase
  test "can be constructed from a record" do
    recipient = Recipient.from_record(recipients(:recipient_2))
    assert_not_nil(recipient.record)
    assert_not_nil(recipient.id)
    assert_not_nil(recipient.name)
    assert_not_nil(recipient.address)
    assert_not_nil(recipient.household)
    assert_length(recipient.household.income_history, 1)
    assert_length(recipient.documents, 1)
  end

  test "adds documents from a message" do
    recipient = Recipient.new(
      id: nil,
      name: nil,
      phone_number: nil,
      address: nil,
      account: nil
    )

    message = Message.new(
      sender: Message::Sender.new(
        phone_number: nil
      ),
      attachments: [
        Message::Attachment.new(
          url: "https://website.com/image.jpg"
        )
      ]
    )

    recipient.add_documents_from_message(message)
    assert_length(recipient.new_documents, 1)
    assert_equal(recipient.new_documents[0].source_url, "https://website.com/image.jpg")
  end
end
