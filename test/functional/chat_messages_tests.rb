require "test_helper"

class ChatMessagesTests < ActionCable::Channel::TestCase
  tests(Chats::MessagesChannel)

  # -- tests --
  test "subscribe a cohere user" do
    chat_rec = chats(:idle_1)
    chat = Chat::Repo.map_record(chat_rec)
    user_rec = users(:cohere_1)
    user = User::Repo.map_record(user_rec)
    stub_connection(chat_user_id: user)

    subscribe(chat: chat_rec.id)
    assert_has_stream_for(chat)
  end

  test "receive and publish a message from a cohere user" do
    chat_rec = chats(:idle_1)

    case_rec = chat_rec.recipient.cases.order(updated_at: :desc).first
    case_rec.has_new_activity = true
    case_rec.save!

    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: "test-sender")
    subscribe(chat: chat_rec.id)

    act = -> do
      VCR.use_cassette("chats--send-cohere-message") do
        perform(:receive, {
          "name" => "ADD_MESSAGE",
          "data" => {
            "chat" => chat_rec.id,
            "message" => {
              "id" => "test-id",
              "body" => "Test from Cohere.",
            },
          },
        })
      end
    end

    assert_difference(
      -> { Chat::Message::Record.count } => 1,
      &act
    )

    assert(
      chat_rec.messages
        .where.not(remote_id: nil).exists?(client_id: "test-id")
    )

    assert_matching_broadcast_on(chat) do |msg|
      assert_equal(msg["name"], "DID_ADD_MESSAGE")

      msg = msg["data"]
      assert_not_nil(msg["id"])
      assert_equal(msg["sender"], "test-sender")
      assert_equal(msg["body"], "Test from Cohere.")
      assert_not_nil(msg["status"])
      assert_not_nil(msg["timestamp"])
      assert_length(msg["attachments"], 0)
    end

    assert_broadcast_on(case_activity_for(:cohere_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_has_new_activity: false,
      }
    })
  end

  test "receive and publish attachments from a cohere user" do
    chat_rec = chats(:idle_1)
    blob_rec = active_storage_blobs(:blob_1)

    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: "test-sender")
    subscribe(chat: chat_rec.id)

    act = -> do
      VCR.use_cassette("chats--send-cohere-message--attachments") do
        perform(:receive, {
          "name" => "ADD_MESSAGE",
          "data" => {
            "chat" => chat_rec.id,
            "message" => {
              "id" => "test-id",
              "body" => "Test with attachments.",
              "attachment_ids" => [blob_rec.id]
            },
          },
        })
      end
    end

    assert_difference(
      -> { Chat::Message::Record.count } => 1,
      -> { Chat::Attachment::Record.count } => 1,
      -> { Document::Record.count } => 0,
      &act
    )

    assert_matching_broadcast_on(chat) do |msg|
      attachments = msg["data"]["attachments"]
      assert_length(attachments, 1)

      attachment = attachments[0]
      assert_not_nil(attachment["name"])
      assert_not_nil(attachment["url"])
      assert_not_nil(attachment["preview_url"])
    end

    assert_analytics_events(0)
  end
end
