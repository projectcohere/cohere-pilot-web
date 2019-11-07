require "test_helper"

class CaseTests < ActiveSupport::TestCase
  test "attaches a dhs account" do
    skip
  end

  test "submits to an enroller" do
    skip
  end

  test "uploads documents from a message" do
    kase = Case.new(
      id: 4,
      status: nil,
      recipient: nil,
      account: nil,
      enroller_id: nil,
      supplier_id: nil
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

    documents = kase.upload_documents_from_message(message)
    assert_length(documents, 1)
    assert_equal(documents[0].case_id, 4)
    assert_equal(documents[0].source_url, "https://website.com/image.jpg")
  end
end
