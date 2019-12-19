require "test_helper"

class ChatTests < ActionDispatch::IntegrationTest
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
