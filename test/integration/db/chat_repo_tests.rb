require "test_helper"

module Db
  class ChatRepoTests < ActiveSupport::TestCase
    # -- queries --
    test "tests if a chat exists by phone number" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:idle_1)
      chat_phone_number = chat_rec.recipient.phone_number

      chat_exists = chat_repo.any_by_phone_number?(chat_phone_number)
      assert(chat_exists)

      chat_exists = chat_repo.any_by_phone_number?("9999999999")
      assert_not(chat_exists)
    end

    test "tests if a chat exists for a recipient" do
      chat_repo = Chat::Repo.new

      chat_recipient_rec = chats(:idle_1).recipient
      chat_exists = chat_repo.any_by_recipient?(chat_recipient_rec.id)
      assert(chat_exists)

      chat_recipient_rec = recipients(:recipient_3)
      chat_exists = chat_repo.any_by_recipient?(chat_recipient_rec.id)
      assert_not(chat_exists)
    end

    test "finds a chat by recipient with messages" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:idle_1)

      chat = chat_repo.find_by_recipient_with_messages(chat_rec.recipient_id)
      assert_not_nil(chat)
      assert_equal(chat.id.val, chat_rec.id)
      assert_length(chat.messages, 2)
      assert_match(/First/, chat.messages[0].body)
    end

    test "finds a chat by phone number" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:idle_1)
      phone_number = chat_rec.recipient.phone_number

      chat = chat_repo.find_by_phone_number(phone_number)
      assert_not_nil(chat)
      assert_equal(chat.id.val, chat_rec.id)
    end

    test "finds a chat by selected message" do
      chat_repo = Chat::Repo.new
      chat_message_rec = chat_messages(:message_i1_1)

      chat = chat_repo.find_by_selected_message(chat_message_rec.id)
      assert_not_nil(chat)
      assert_not_nil(chat.selected_message)
      assert_present(chat.selected_message.attachments)
    end

    # -- commands --
    test "saves an opened chat" do
      recipient_rec = recipients(:recipient_3)
      chat_recipient = Chat::Repo.map_recipient(recipient_rec)
      chat = Chat.open(chat_recipient)
      chat_repo = Chat::Repo.new

      act = -> do
        chat_repo.save_opened(chat)
      end

      assert_difference(
        -> { Chat::Record.count } => 1,
        &act
      )

      assert_not_nil(chat.id.val)
      assert_not_nil(chat.record)
    end

    test "saves a new message" do
      domain_events = ArrayQueue.new

      blob_rec = active_storage_blobs(:blob_1)
      chat_rec = chats(:idle_1)
      chat = Chat::Repo.map_record(chat_rec)
      chat.add_message(
        sender: Chat::Sender.automated,
        body: "Test.",
        attachments: [blob_rec]
      )

      message_id = chat.new_message.id

      chat_repo = Chat::Repo.new(domain_events: domain_events)
      act = -> do
        chat_repo.save_new_message(chat)
      end

      assert_difference(
        -> { Chat::Message::Record.count } => 1,
        -> { ActiveStorage::Attachment.count } => 1,
        &act
      )

      chat_rec = chat_rec
      assert_not(chat_rec.saved_change_to_attribute?(:updated_at))

      message_rec = chat_rec.messages
        .find { |r| r.id == message_id.val }

      assert_not_nil(message_rec.id)
      assert_equal(message_rec.sender, Chat::Sender.automated)
      assert_equal(message_rec.body, "Test.")

      attachment_rec = message_rec.files[0]
      assert_not_nil(attachment_rec, 1)
      assert_equal(attachment_rec.blob, blob_rec)

      assert_nil(chat.new_message)
      assert_length(chat.events, 0)
      assert_length(domain_events, 1)
    end
  end
end
