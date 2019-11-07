require "test_helper"
require "minitest/mock"

class Document
  class UploadFromMessageTests < ActiveSupport::TestCase
    test "uploads documents from message attachments" do
      message = Message.new(
        sender: Message::Sender.new(
          phone_number: "111-222-3333"
        ),
        attachments: [
          Message::Attachment.new(
            url: "https://website.com/image.jpg"
          )
        ]
      )

      case_repo = Minitest::Mock.new
        .expect(
          :find_by_phone_number,
          Case.new(status: nil, account: nil, recipient: nil, enroller_id: nil, supplier_id: nil),
          ["111-222-3333"]
        )

      document_repo = Minitest::Mock.new
        .expect(:save_uploaded, nil, [Array])

      upload = UploadFromMessage.new(
        decode_message: ->(_) { message },
        case_repo: case_repo,
        document_repo: document_repo
      )

      documents = upload.("ignored-data")
      assert_length(documents, 1)
      assert_equal(documents[0].source_url, "https://website.com/image.jpg")
    end

    test "raises an error if the case is missing" do
      message = Message.new(
        sender: Message::Sender.new(
          phone_number: "111-222-3333"
        ),
        attachments: [
          Message::Attachment.new(
            url: "https://website.com/image.jpg"
          )
        ]
      )

      case_repo = Minitest::Mock.new
        .expect(:find_by_phone_number, nil, ["111-222-3333"])

      upload = UploadFromMessage.new(
        decode_message: ->(_) { message },
        case_repo: case_repo
      )

      act = -> do
        upload.("ignored-data")
      end

      assert_raises(&act)
    end
  end
end
