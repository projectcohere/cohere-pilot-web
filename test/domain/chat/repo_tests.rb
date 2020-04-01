require "test_helper"

class Chat
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      chat_rec = chats(:idle_1)
      chat_message_rec = chat_rec.messages[0]

      chat = Chat::Repo.map_record(chat_rec, [Chat::Message::Repo.map_record(chat_message_rec)])
      assert_not_nil(chat.record)
      assert_not_nil(chat.id&.val)
      assert_not_nil(chat.recipient.id)

      message = chat.messages[0]
      assert_not_nil(message)
      assert_not_nil(message.id.val)
      assert_not_nil(message.sender)
      assert_not_nil(message.body)
    end
  end
end
