require "test_helper"

class ChatTests < ActionDispatch::IntegrationTest
  # -- connect --
  test "can't start a chat chat session with an invalid token" do
    get("/chat/connect?remember_token=fake")
    assert_redirected_to("/chat/join")
  end

  test "start a new chat session" do
    chat_rec = chats(:chat_1)
    chat_token = chat_rec.remember_token

    get("/chat/connect?remember_token=#{chat_token}")
    assert_equal(session[:remember_token], "1F9A0JP")
    assert_redirected_to("/chat")
  end

  # -- show --
  test "can't chat without establishing a session" do
    get("/chat")
    assert_redirected_to("/chat/join")
  end

  test "show the chat view" do
  end
end
