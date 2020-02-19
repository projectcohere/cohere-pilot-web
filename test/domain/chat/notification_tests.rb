require "test_helper"

class Chat
  class NotificationTests < ActiveSupport::TestCase
    def stub_name
      return ::Recipient::Name.stub(
        first: "JANICE",
        last: "SAMPLE",
      )
    end

    # -- queries --
    test "has an introduction for new conversations" do
      notification = Notification.stub(
        recipient_name: stub_name,
        is_new_conversation: true,
      )

      assert_match(/Hi Janice, this is Gaby from Cohere/, notification.text)
    end

    test "has the right number of lines" do
      notification = Notification.stub(
        recipient_name: stub_name,
        is_new_conversation: true,
      )

      assert_length(notification.text.split(". "), 3)
    end

    test "has a link to the chat" do
      notification = Notification.stub(
        recipient_name: stub_name,
      )

      assert_match(%r[on the Cohere web chat], notification.text)
      assert_match(%r[https://projectcohere.com], notification.text)
    end
  end
end
