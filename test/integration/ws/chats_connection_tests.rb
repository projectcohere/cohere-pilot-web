require "test_helper"

module Ws
  class ChatsConnectionTests < ActionCable::Connection::TestCase
    tests(Chats::Connection)

    # -- setup --
    def setup
      cookies[:encrypted] = Encrypted.new
    end

    # -- setup/classes
    class Encrypted
      def signed
        @signed ||= {}
      end
    end

    # -- tests --
    test "connect a user by remember token" do
      user_rec = users(:cohere_1)
      cookies[:remember_token] = user_rec.remember_token
      cookies.signed[:chat_user_id] = "test-id"

      connect
      assert_equal(connection.chat_user_id, "test-id")
    end

    test "connect a chat by recipient token" do
      chat_rec = chats(:chat_1)
      cookies.encrypted.signed[:chat_recipient_token] = chat_rec.recipient_token

      connect
      assert_not_nil(connection.chat)
      assert_equal(connection.chat.id.val, chat_rec.id)
    end
  end
end
