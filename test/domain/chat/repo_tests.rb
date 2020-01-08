require "test_helper"

class Chat
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      chat_rec = chats(:chat_1)
      case_rec = cases(:opened_1)

      chat = Chat::Repo.map_record(chat_rec, chat_rec.messages, case_rec)
      assert_not_nil(chat.record)
      assert_not_nil(chat.id&.val)
      assert_not_nil(chat.recipient_token)
      assert_not_nil(chat.current_case_id)

      token = chat.recipient_token
      assert_not_nil(token.val)
      assert_not_nil(token.expires_at)

      message = chat.messages[0]
      assert_not_nil(message)
      assert_not_nil(message.id.val)
      assert_equal(message.type, Chat::Type::Text)
      assert_not_nil(message.sender)
      assert_not_nil(message.body)
    end
  end
end
