require "test_helper"

module Db
  class ChatRepoTests < ActiveSupport::TestCase
    # -- queries --
    test "find a chat by recipient token" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:chat_1)

      chat = chat_repo.find_by_recipient_token(chat_rec.recipient_token)
      assert_not_nil(chat)
      assert_equal(chat.id.val, chat_rec.id)
    end

    test "does not find a chat with an expired recipient token" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:chat_2)

      chat = chat_repo.find_by_recipient_token(chat_rec.recipient_token)
      assert_nil(chat)
    end

    test "find a chat with a selected message" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:chat_1)

      chat = chat_repo.find_with_message(chat_rec.id, 0)
      assert_equal(chat&.id&.val, chat_rec.id)
      assert_equal(chat&.selected_message&.id, 0)
    end

    test "does not find a chat with a missing message" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:chat_2)

      assert_raises(ActiveRecord::RecordNotFound) do
        chat_repo.find_with_message(chat_rec.id, 0)
      end
    end

    # -- commands --
    test "save new messages" do
      domain_events = ArrayQueue.new

      chat_rec = chats(:chat_2)
      chat = Chat::Repo.map_record(chat_rec)
      chat.add_message(
        sender: Chat::Sender::Cohere,
        type: Chat::Type::Text,
        body: "Test."
      )

      chat_repo = Chat::Repo.new(domain_events: domain_events)
      act = -> do
        chat_repo.save_new_messages(chat)
      end

      assert_difference(
        -> { chat_rec.messages.count } => 1,
        &act
      )

      message_rec = chat_rec.messages[0]
      assert_equal(message_rec["id"], 0)
      assert_equal(message_rec["sender"], Chat::Sender::Cohere.to_s)
      assert_equal(message_rec["type"], Chat::Type::Text.to_s)
      assert_equal(message_rec["body"], "Test.")

      assert_nil(chat.new_messages)
      assert_length(chat.events, 0)
      assert_length(domain_events, 1)
    end
  end
end
