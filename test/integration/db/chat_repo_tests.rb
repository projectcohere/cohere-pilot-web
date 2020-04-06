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
      chat_repo = Chat::Repo.new
      chat_rec = chats(:idle_1)
      blob_rec = active_storage_blobs(:blob_1)

      chat = Chat::Repo.map_record(chat_rec)
      chat.add_message(
        sender: Chat::Sender.automated,
        body: "Test.",
        files: [blob_rec],
        status: Chat::Message::Status::Queued,
      )

      act = -> do
        chat_repo.save_new_message(chat)
      end

      assert_difference(
        -> { Chat::Message::Record.count } => 1,
        -> { Chat::Attachment::Record.count } => 1,
        &act
      )

      chat_rec = chat_rec
      assert_not(chat_rec.saved_change_to_attribute?(:updated_at))

      message_rec = chat_rec.messages.find { |r| r.id == chat.new_message.id.val }
      assert_equal(message_rec.sender, Chat::Sender.automated)
      assert_equal(message_rec.body, "Test.")
      assert_equal(message_rec.status, "queued")

      attachment_rec = message_rec.attachments[0]
      assert_not_nil(attachment_rec)
      assert_equal(attachment_rec.file, blob_rec)

      events = chat.events
      assert_length(events, 0)
      assert_length(Service::Container.domain_events, 1)
    end

    test "saves a new message with remote attachments" do
      chat_repo = Chat::Repo.new
      chat_rec = chats(:idle_1)
      chat = Chat::Repo.map_record(chat_rec)
      chat.add_message(
        sender: Chat::Sender.recipient,
        body: "Test.",
        files: [Sms::Media.new(url: "http://website.com/image.jpg")],
        status: Chat::Message::Status::Received,
        remote_id: "SM1239",
      )

      act = -> do
        chat_repo.save_new_message(chat)
      end

      assert_difference(
        -> { Chat::Attachment::Record.count } => 1,
        -> { ActiveStorage::Blob.count } => 0,
        &act
      )

      message_rec = chat_rec.messages.find { |r| r.id == chat.new_message.id.val }
      assert_equal(message_rec.sender, Chat::Sender.recipient)
      assert_equal(message_rec.status, "received")
      assert_equal(message_rec.remote_id, "SM1239")

      attachment_rec = message_rec.attachments[0]
      assert_not_nil(attachment_rec)
      assert_nil(attachment_rec.file)
      assert_equal(attachment_rec.remote_url, "http://website.com/image.jpg")
    end
  end
end
