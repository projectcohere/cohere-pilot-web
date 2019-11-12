require "test_helper"
require "minitest/mock"

class Case
  class UploadMessageAttachmentsTests < ActiveSupport::TestCase
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

      kase = Case.stub
      case_repo = Minitest::Mock.new
        .expect(
          :find_by_phone_number,
          kase,
          ["111-222-3333"]
        )
        .expect(
          :save_new_documents,
          nil,
          [kase]
        )

      upload = UploadMessageAttachments.new(
        decode_message: ->(_) { message },
        case_repo: case_repo,
      )

      documents = upload.("ignored-data")
      assert_mock(case_repo)
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

      upload = UploadMessageAttachments.new(
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
