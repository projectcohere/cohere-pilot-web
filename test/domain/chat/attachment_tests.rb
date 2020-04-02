require "test_helper"

class Chat
  class AttachmentTests < ActiveSupport::TestCase
    # -- commands --
    test "uploads a file" do
      attachment = Attachment.stub(
        remote_url: :test_url,
      )

      attachment.upload_file(:test_file)
      assert_nil(attachment.remote_url)
      assert_equal(attachment.file, :test_file)
    end
  end
end
