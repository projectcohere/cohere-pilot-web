require "test_helper"
require "minitest/mock"

module Cases
  class AddMmsMessageTests < ActiveSupport::TestCase
    test "uploads documents from message attachments" do
      message = Mms::Message.new(
        sender: Mms::Sender.new(
          phone_number: "111-222-3333"
        ),
        attachments: [
          Mms::Attachment.new(
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
          :save_new_message,
          nil,
          [kase]
        )

      upload = AddMmsMessage.new(case_repo: case_repo)
      upload.(message)
      assert_mock(case_repo)
    end

    test "raises an error if the case is missing" do
      message = Mms::Message.new(
        sender: Mms::Sender.new(
          phone_number: "111-222-3333"
        ),
        attachments: [
          Mms::Attachment.new(
            url: "https://website.com/image.jpg"
          )
        ]
      )

      case_repo = Minitest::Mock.new
        .expect(:find_by_phone_number, nil, ["111-222-3333"])

      upload = AddMmsMessage.new(case_repo: case_repo)

      assert_raises do
        upload.(message)
      end
    end
  end
end
