require "test_helper"

class ChatMessagesTests < ActionCable::Channel::TestCase
  tests(Chats::MessageChannel)

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
    chat_message_timestamp = 7

    chat_rec = chats(:idle_1)

    case_rec = chat_rec.recipient.cases.order(updated_at: :desc).first
    case_rec.has_new_activity = true
    case_rec.save!

    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: "test-id")
    subscribe(chat: chat_rec.id)

    act = -> do
      Time.stub(:now, Time.at(chat_message_timestamp)) do
        VCR.use_cassette("chats--send-cohere-message") do
          perform(:receive, {
            "chat" => chat_rec.id,
            "message" => {
              "body" => "Test from Cohere.",
            },
          })
        end
      end
    end

    assert_difference(
      -> { Chat::Message::Record.count } => 1,
      &act
    )

    assert_broadcast_on(chat, {
      sender: Chat::Sender.cohere("test-id"),
      message: {
        body: "Test from Cohere.",
        timestamp: chat_message_timestamp,
        attachments: [],
      },
    })

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
    stub_connection(chat_user_id: "test-id")
    subscribe(chat: chat_rec.id)

    act = -> do
      VCR.use_cassette("chats--send-cohere-message--attachments") do
        perform(:receive, {
          "chat" => chat_rec.id,
          "message" => {
            "body" => "Test with attachments.",
            "attachment_ids" => [blob_rec.id]
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

    assert_broadcasts_on(chat, 1) do |broadcasts|
      attachments = broadcasts[0]["message"]["attachments"]
      assert_length(attachments, 1)
      assert_not_nil(attachments[0]["name"])
      assert_not_nil(attachments[0]["url"])
    end

    assert_analytics_events(0)
  end
end
