require "test_helper"

class Chat
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      chat = Chat::Repo.map_record(chats(:chat_1))
      assert_not_nil(chat.record)
      assert_not_nil(chat.id&.val)
      assert_not_nil(chat.recipient_token)

      token = chat.recipient_token
      assert_not_nil(token.val)
      assert_not_nil(token.expires_at)
    end
  end
end