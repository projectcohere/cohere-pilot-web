require "test_helper"

module Ws
  class ConnectionTests < ActionCable::Connection::TestCase
    tests(ApplicationCable::Connection)

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

      connect
      assert_equal(connection.user.id.val, user_rec.id)
      assert_nil(connection.chat_user_id)
    end

    test "connect by a user with a chat id by remember token" do
      user_rec = users(:cohere_1)
      cookies[:remember_token] = user_rec.remember_token
      cookies.signed[:chat_user_id] = "test-id"

      connect
      assert_equal(connection.user.id.val, user_rec.id)
      assert_equal(connection.chat_user_id, "test-id")
    end
  end
end
