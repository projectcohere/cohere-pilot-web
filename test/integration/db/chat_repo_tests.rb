require "test_helper"

module Db
  class ChatRepoTests < ActiveSupport::TestCase
    # -- queries --
    test "find a chat by recipient with messages" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:chat_1)

      chat = chat_repo.find_by_recipient_with_messages(chat_rec.recipient_id)
      assert_not_nil(chat)
      assert_equal(chat.id.val, chat_rec.id)
      assert_length(chat.messages, 1)
    end

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

      assert_raises(ActiveRecord::RecordNotFound) do
        chat_repo.find_by_recipient_token(chat_rec.recipient_token)
      end
    end

    test "find a chat by recipient token with messages" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:chat_1)

      chat = chat_repo.find_by_recipient_token_with_messages(chat_rec.recipient_token)
      assert_not_nil(chat)
      assert_equal(chat.id.val, chat_rec.id)
      assert_length(chat.messages, 1)
    end

    test "find a chat by recipient token with its current case" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:chat_1)

      chat = chat_repo.find_by_recipient_token_with_current_case(chat_rec.recipient_token)
      assert_not_nil(chat)
      assert_not_nil(chat.current_case_id)
    end

    test "does not find a chat with a missing current case" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:chat_3)

      assert_raises(ActiveRecord::RecordNotFound) do
        chat_repo.find_by_recipient_token_with_current_case(chat_rec.recipient_token)
      end
    end

    # -- commands --
    test "save new messages" do
      domain_events = ArrayQueue.new

      chat_rec = chats(:chat_2)
      chat = Chat::Repo.map_record(chat_rec)
      chat.add_message(
        sender: Chat::Sender.recipient,
        type: Chat::Type::Text,
        body: "Test."
      )

      chat_repo = Chat::Repo.new(domain_events: domain_events)
      act = -> do
        chat_repo.save_new_messages(chat)
      end

      assert_difference(
        -> { Chat::Message::Record.count } => 1,
        &act
      )

      message_rec = chat_rec.messages.reload[0]
      assert_not_nil(message_rec.id)
      assert_equal(message_rec.sender, Chat::Sender.recipient)
      assert_equal(message_rec.mtype.to_sym, Chat::Type::Text)
      assert_equal(message_rec.body, "Test.")

      assert_nil(chat.new_messages)
      assert_length(chat.events, 0)
      assert_length(domain_events, 1)
    end
  end
end
