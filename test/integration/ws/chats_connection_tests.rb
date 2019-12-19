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
    test "connects with a recipient token" do
      chat_rec = chats(:chat_1)
      chat_token = chat_rec.recipient_token
      cookies.encrypted.signed[:recipient_token] = chat_token

      connect
      assert_not_nil(connection.current_chat)
      assert_equal(connection.current_chat.recipient_token.value, chat_token)
    end
  end
end
