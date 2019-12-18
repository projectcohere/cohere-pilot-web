require "test_helper"

module Db
  class ChatRepoTests < ActiveSupport::TestCase
    test "does not find a chat with an expired remember token" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:chat_2)

      chat = chat_repo.find_by_remember_token(chat_rec.remember_token)
      assert_nil(chat)
    end

    test "finds a chat by remember token" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:chat_1)

      chat = chat_repo.find_by_remember_token(chat_rec.remember_token)
      assert_not_nil(chat)
      assert_equal(chat.id.val, chat_rec.id)
    end
  end
end
