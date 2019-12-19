require "test_helper"

module Ws
  class ChatsChannelTests < ActionCable::Channel::TestCase
    tests(Chats::Channel)

    # -- tests --
    test "subscribe a recipient" do
      chat_rec = chats(:chat_1)
      chat = Chat::Repo.map_record(chat_rec)
      stub_connection(current_chat: chat)

      subscribe
      assert_has_stream_for(chat)
    end
  end
end
