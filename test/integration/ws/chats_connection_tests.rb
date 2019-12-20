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
      user_token = user_rec.remember_token
      cookies[:remember_token] = user_token

      connect
      assert_not_nil(connection.current_user)
      assert_equal(connection.current_user.id.val, user_rec.id)
    end

    test "connect a chat by recipient token" do
      chat_rec = chats(:chat_1)
      cookies.encrypted.signed[:recipient_token] = chat_rec.recipient_token

      connect
      assert_not_nil(connection.current_chat)
      assert_equal(connection.current_chat.id.val, chat_rec.id)
    end
  end
end
