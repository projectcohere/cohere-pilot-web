require "test_helper"

class ChatsTests < ActionDispatch::IntegrationTest
  # -- connect --
  test "connect to a new chat session" do
    get("/chat/connect?recipient_token=test-token")
    assert_not_nil(cookies[:chat_recipient_token])
    assert_redirected_to("/chat")
  end

  # -- show --
  test "can't chat without establishing a session" do
    get("/chat")
    assert_redirected_to("/chat/join")
  end

  test "can't chat with an unknown token" do
    get("/chat/connect?recipient_token=fake-token")
    follow_redirect!

    assert_redirected_to("/chat/join")
    assert_blank(cookies[:chat_recipient_token])
  end

  test "can't chat with an expired token" do
    chat_rec = chats(:chat_2)
    chat_token = chat_rec.recipient_token

    get("/chat/connect?recipient_token=#{chat_token}")
    follow_redirect!

    assert_redirected_to("/chat/join")
    assert_blank(cookies[:chat_recipient_token])
  end

  test "show the chat view" do
    chat_rec = chats(:chat_1)
    chat_token = chat_rec.recipient_token

    get("/chat/connect?chat_recipient_token=#{chat_token}")
    follow_redirect!

    assert_response(:success)
    assert_present(cookies[:chat_recipient_token])
  end
end

class ChatsChannelTests < ActionCable::Channel::TestCase
  tests(Chats::Channel)

  # -- tests --
  test "subscribe a cohere user" do
    chat_rec = chats(:chat_1)
    chat = Chat::Repo.map_record(chat_rec)
    user_rec = users(:cohere_1)
    user = User::Repo.map_record(user_rec)
    stub_connection(chat_user_id: user, chat: nil)

    subscribe(chat: chat_rec.id)
    assert_has_stream_for(chat)
  end

  test "subscribe a recipient" do
    chat_rec = chats(:chat_1)
    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: nil, chat: chat)

    subscribe
    assert_has_stream_for(chat)
  end

  test "receives and broadcasts a text message from a cohere user" do
    Sidekiq::Testing.inline!

    chat_rec = chats(:chat_1)
    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: "test-id", chat: nil)

    subscribe
    perform(:receive, {
      "chat" => chat_rec.id,
      "message" => {
        "type" => Chat::Type::Text.to_s,
        "body" => "Test from Cohere."
      }
    })

    assert_broadcast_on(chat, {
      sender: Chat::Sender.cohere("test-id"),
      message: {
        type: Chat::Type::Text,
        body: "Test from Cohere."
      }
    })
  end

  test "receives and broadcasts a text message from a recipient" do
    Sidekiq::Testing.inline!

    chat_rec = chats(:chat_1)
    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(chat_user_id: nil, chat: chat)

    subscribe
    perform(:receive, {
      "chat" => nil,
      "message" => {
        "type" => Chat::Type::Text.to_s,
        "body" => "Test from recipient."
      }
    })

    assert_broadcast_on(chat, {
      sender: Chat::Sender.recipient,
      message: {
        type: Chat::Type::Text,
        body: "Test from recipient."
      }
    })
  end
end
