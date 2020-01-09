require "test_helper"

module Db
  class ChatRepoTests < ActiveSupport::TestCase
    # -- queries --
    test "finds a chat by recipient with messages" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:invited_1)

      chat = chat_repo.find_by_recipient_with_messages(chat_rec.recipient_id)
      assert_not_nil(chat)
      assert_equal(chat.id.val, chat_rec.id)
      assert_length(chat.messages, 1)
    end

    test "finds a chat by invitation" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:invited_1)
      chat_invite = chat_rec.invitation_token

      chat = chat_repo.find_by_invitation(chat_invite)
      assert_not_nil(chat)
      assert_equal(chat.id.val, chat_rec.id)
    end

    test "does not find a chat with an expired invitation" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:expired_1)
      chat_invite = chat_rec.invitation_token

      chat = chat_repo.find_by_invitation(chat_invite)
      assert_nil(chat)
    end

    test "finds a chat by session with messages" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:session_1)
      chat_session = chat_rec.session_token

      chat = chat_repo.find_by_session_with_messages(chat_session)
      assert_not_nil(chat)
      assert_equal(chat.id.val, chat_rec.id)
      assert_length(chat.messages, 1)
    end

    test "does not find a chat with no session" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:invited_1)
      chat_session = chat_rec.session_token

      chat = chat_repo.find_by_session_with_messages(chat_session)
      assert_nil(chat)
    end

    test "finds a chat by session with its current case" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:session_1)
      chat_session = chat_rec.session_token

      chat = chat_repo.find_by_session_with_current_case(chat_session)
      assert_not_nil(chat)
      assert_not_nil(chat.current_case_id)
    end

    test "does not find a chat with a missing current case" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:session_2)
      chat_session = chat_rec.session_token

      assert_raises(ActiveRecord::RecordNotFound) do
        chat_repo.find_by_session_with_current_case(chat_session)
      end
    end

    # -- commands --
    test "saves a new session" do
      chat_rec = chats(:invited_1)
      chat = Chat::Repo.map_record(chat_rec)
      chat.start_session

      chat_repo = Chat::Repo.new
      chat_repo.save_new_session(chat)

      assert_nil(chat_rec.invitation_token)
      assert_nil(chat_rec.invitation_token_expires_at)
      assert_not_nil(chat_rec.session_token)
    end

    test "saves new messages" do
      domain_events = ArrayQueue.new

      chat_rec = chats(:expired_1)
      chat = Chat::Repo.map_record(chat_rec)
      chat.add_message(
        sender: Chat::Sender.recipient,
        body: "Test.",
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
      assert_equal(message_rec.body, "Test.")

      assert_nil(chat.new_messages)
      assert_length(chat.events, 0)
      assert_length(domain_events, 1)
    end
  end
end
