require "test_helper"

class ChatsTests < ActionDispatch::IntegrationTest
  # -- join -0-
  test "views prompt to join chat" do
    get("/chat/join")
    assert_redirected_to("/chat/invites/new")
  end

  # -- show --
  test "show the chat" do
    chat_rec = chats(:session_1)
    post("/tests/chat-session", params: {
      token: chat_rec.session_token,
    })

    get("/chat")
    assert_response(:success)
    assert_present(cookies[:chat_session_token])
  end

  test "can't chat without establishing a session" do
    get("/chat")
    assert_redirected_to("/chat/join")
  end

  # -- files --
  test "can't upload files with an unknown request format" do
    assert_raises(ActionController::RoutingError) do
      post("/chat/files", as: :json)
    end
  end

  test "can't upload files if not connected" do
    post("/chat/files", params: {
      files: {
        "0" => fixture_file_upload("files/test.txt", "text/plain")
      }
    })

    assert_response(:not_found)
  end

  test "upload files for the current chat" do
    chat_rec = chats(:session_1)
    post("/tests/chat-session", params: {
      token: chat_rec.session_token,
    })

    act = -> do
      post("/chat/files", params: {
        files: {
          "0" => fixture_file_upload("files/test.txt", "text/plain")
        }
      })
    end

    assert_difference(
      -> { ActiveStorage::Blob.count } => 1,
      &act
    )

    assert_response(:success)

    res = JSON.parse(response.body)
    assert_length(res["data"]["fileIds"], 1)
  end

  test "can't upload without permission" do
    user_rec = users(:dhs_1)
    chat_rec = chats(:idle_1)

    act = -> do
      post(auth("/chat/#{chat_rec.id}/files", as: user_rec), params: {
        files: {
          "0" => fixture_file_upload("files/test.txt", "text/plain")
        }
      })
    end

    assert_raises(ActionController::RoutingError, &act)
  end

  test "upload files as a cohere user" do
    user_rec = users(:cohere_1)
    chat_rec = chats(:idle_1)

    act = -> do
      post(auth("/chats/#{chat_rec.id}/files", as: user_rec), params: {
        files: {
          "0" => fixture_file_upload("files/test.txt", "text/plain")
        }
      })
    end

    assert_difference(
      -> { ActiveStorage::Blob.count } => 1,
      &act
    )

    assert_response(:success)

    res = JSON.parse(response.body)
    assert_length(res["data"]["fileIds"], 1)
  end
end

class ChatsChannelTests < ActionCable::Channel::TestCase
  tests(Chats::Channel)

  # -- tests --
  test "subscribe a cohere user" do
    chat_rec = chats(:idle_1)
    chat = Chat::Repo.map_record(chat_rec)
    user_rec = users(:cohere_1)
    user = User::Repo.map_record(user_rec)
    stub_connection(chat_user_id: user, chat: nil)

    subscribe(chat: chat_rec.id)
    assert_has_stream_for(chat)
  end

  test "subscribe a recipient" do
    chat_rec = chats(:idle_1)
    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: nil, chat: chat)

    subscribe
    assert_has_stream_for(chat)
  end

  test "receive and deliver a message from a cohere user" do
    Sidekiq::Testing.inline!

    chat_rec = chats(:idle_1)
    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: "test-id", chat: nil)
    subscribe(chat: chat_rec.id)

    act = -> do
      perform(:receive, {
        "chat" => chat_rec.id,
        "message" => {
          "body" => "Test from Cohere.",
        },
      })
    end

    assert_difference(
      -> { Chat::Message::Record.count } => 1,
      &act
    )

    assert_broadcast_on(chat, {
      sender: Chat::Sender.cohere("test-id"),
      message: {
        body: "Test from Cohere.",
        attachments: []
      },
    })
  end

  test "receive and deliver a message from a recipient" do
    Sidekiq::Testing.inline!

    chat_rec = chats(:idle_1)
    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: nil, chat: chat)
    subscribe

    act = -> do
      perform(:receive, {
        "chat" => nil,
        "message" => {
          "body" => "Test from recipient.",
        },
      })
    end

    assert_difference(
      -> { Chat::Message::Record.count } => 1,
      &act
    )

    assert_broadcast_on(chat, {
      sender: Chat::Sender.recipient,
      message: {
        body: "Test from recipient.",
        attachments: []
      },
    })
  end

  test "receive and deliver a message with attachments" do
    Sidekiq::Testing.inline!

    blob_rec = active_storage_blobs(:blob_1)
    chat_rec = chats(:idle_1)
    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: nil, chat: chat)
    subscribe

    act = -> do
      perform(:receive, {
        "chat" => nil,
        "message" => {
          "body" => "Test with attachments.",
          "attachmentIds" => [blob_rec.id]
        },
      })
    end

    assert_difference(
      -> { Chat::Message::Record.count } => 1,
      -> { Document::Record.count } => 1,
      -> { ActiveStorage::Attachment.count } => 2,
      &act
    )

    assert_broadcasts_on(chat, 1) do |broadcasts|
      attachments = broadcasts[0]["message"]["attachments"]
      assert_length(attachments, 1)

      attachment = attachments[0]
      assert_not_nil(attachment["name"])
      assert_not_nil(attachment["url"])
    end

    assert_analytics_events(1) do |events|
      assert_match(/Did Receive Message/, events[0])
    end
  end
end
