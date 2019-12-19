require "test_helper"

class ChatsTests < ActionDispatch::IntegrationTest
  # -- connect --
  test "can't start a chat chat session with an invalid token" do
    get("/chat/connect?recipient_token=fake")
    assert_redirected_to("/chat/join")
  end

  test "start a new chat session" do
    chat_rec = chats(:chat_1)
    chat_token = chat_rec.recipient_token

    get("/chat/connect?recipient_token=#{chat_token}")
    assert_not_nil(cookies[:recipient_token])
    assert_redirected_to("/chat")
  end

  # -- show --
  test "can't chat without establishing a session" do
    get("/chat")
    assert_redirected_to("/chat/join")
  end

  test "show the chat view" do
    chat_rec = chats(:chat_1)
    chat_token = chat_rec.recipient_token

    get("/chat/connect?recipient_token=#{chat_token}")
    follow_redirect!

    assert_response(:success)
  end
end

class ChatsChannelTests < ActionCable::Channel::TestCase
  tests(Chats::Channel)

  # -- tests --
  test "subscribe a recipient" do
    chat_rec = chats(:chat_1)
    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(current_chat: chat)

    subscribe
    assert_has_stream_for(chat)
  end

  test "receives and broadcasts a text message" do
    Sidekiq::Testing.inline!

    chat_rec = chats(:chat_1)
    chat = Chat::Repo.map_record(chat_rec)
    stub_connection(current_chat: chat)

    subscribe
    perform(:receive, {
      type: Chat::Type::Text,
      body: "Test body."
    })

    assert_broadcast_on(chat, {
      sender: Chat::Sender::Recipient,
      message: {
        type: Chat::Type::Text,
        body: "Test body."
      }
    })
  end
end
