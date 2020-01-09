require "test_helper"

class Chat
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      chat_rec = chats(:invited_1)
      case_rec = cases(:opened_1)

      chat = Chat::Repo.map_record(chat_rec, chat_rec.messages, case_rec)
      assert_not_nil(chat.record)
      assert_not_nil(chat.id&.val)
      assert_nil(chat.session)
      assert_not_nil(chat.current_case_id)

      invitation = chat.invitation
      assert_not_nil(invitation)
      assert_not_nil(invitation.token)
      assert_not_nil(invitation.expires_at)

      message = chat.messages[0]
      assert_not_nil(message)
      assert_not_nil(message.id.val)
      assert_equal(message.type, Chat::Type::Text)
      assert_not_nil(message.sender)
      assert_not_nil(message.body)

      chat_rec = chats(:session_1)

      chat = Chat::Repo.map_record(chat_rec)
      assert_not_nil(chat.session)
    end
  end
end
