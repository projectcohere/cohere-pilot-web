require "test_helper"

class ChatsTests < ActionDispatch::IntegrationTest
  # -- start --
  test "start a session" do
    chat_rec = chats(:invited_1)
    chat_invite = chat_rec.invitation_token

    get("/chat/start/#{chat_invite}")
    assert_not_nil(cookies[:chat_session_token])
    assert_redirected_to("/chat")
  end

  test "can't start a session with an unknown token" do
    get("/chat/start/fake-token")

    assert_redirected_to("/chat/join")
    assert_blank(cookies[:chat_session_token])
  end

  test "can't start a session with an expired token" do
    chat_rec = chats(:expired_1)
    chat_invite = chat_rec.invitation_token

    get("/chat/start/#{chat_invite}")
    assert_redirected_to("/chat/join")
    assert_blank(cookies[:chat_session_token])
  end

  # -- show --
  test "show the chat" do
    chat_rec = chats(:invited_1)
    chat_invite = chat_rec.invitation_token

    get("/chat/start/#{chat_invite}")
    follow_redirect!

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
    assert_raises(ActionController::RoutingError) do
      post("/chat/files", params: {
        files: {
          "0" => fixture_file_upload("files/test.txt", "text/plain")
        }
      })
    end
  end

  test "upload files for the current chat" do
    chat_rec = chats(:invited_1)
    chat_invite = chat_rec.invitation_token
    get("/chat/start/#{chat_invite}")

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
end

class ChatsChannelTests < ActionCable::Channel::TestCase
  tests(Chats::Channel)

  # -- tests --
  test "subscribe a cohere user" do
    chat_rec = chats(:invited_1)
    chat = Chat::Repo.map_record(chat_rec)
    user_rec = users(:cohere_1)
    user = User::Repo.map_record(user_rec)
    stub_connection(chat_user_id: user, chat: nil)

    subscribe(chat: chat_rec.id)
    assert_has_stream_for(chat)
  end

  test "subscribe a recipient" do
    chat_rec = chats(:invited_1)
    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: nil, chat: chat)

    subscribe
    assert_has_stream_for(chat)
  end

  test "receive and deliver a message from a cohere user" do
    Sidekiq::Testing.inline!

    chat_rec = chats(:invited_1)
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

    chat_rec = chats(:invited_1)
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
    chat_rec = chats(:invited_1)
    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: nil, chat: chat)
    subscribe

    ActiveStorage::Current.host = "https://test.com"

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
      -> { ActiveStorage::Attachment.count } => 1,
      &act
    )

    broadcast = broadcasts(broadcasting_for(chat))[0]
    assert_not_nil(broadcast)

    outgoing = ActiveSupport::JSON.decode(broadcast)
    outgoing_attachments = outgoing["message"]["attachments"]
    assert_length(outgoing_attachments, 1)
    assert_not_nil(outgoing_attachments[0]["preview_url"])
  end
end
