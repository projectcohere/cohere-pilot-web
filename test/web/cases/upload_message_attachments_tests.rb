require "test_helper"
require "minitest/mock"

module Cases
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

      upload = UploadMessageAttachments.new(case_repo: case_repo)
      upload.(message)
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

      upload = UploadMessageAttachments.new(case_repo: case_repo)

      assert_raises do
        upload.(message)
      end
    end
  end
end
