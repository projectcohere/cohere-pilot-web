require "test_helper"

class ChatsInvitesTests < ActionDispatch::IntegrationTest
  include ActiveSupport::NumberHelper

  # -- new --
  test "views prompt to request an invite" do
    get("/chat/invites/new")
    assert_response(:success)
  end

  test "requests an invite" do
    chat_rec = chats(:idle_1)

    VCR.use_cassette("chats--request-invite") do
      post("/chat/invites", params: {
        invite: {
          phone_number: number_to_phone(chat_rec.recipient.phone_number)
        }
      })
    end

    assert_redirected_to("/chat/invites/verify")
    assert_present(cookies[:chat_invite_sid])
    assert_present(cookies[:chat_invite_phone_number])
  end

  # -- create --
  test "can't send an invite if the chat does not exist" do
    post("/chat/invites", params: {
      invite: {
        phone_number: "(999) 999-9999"
      }
    })

    assert_response(:success)
    assert_present(flash.now[:alert])
    assert_blank(cookies[:chat_invite_sid])
    assert_blank(cookies[:chat_invite_phone_number])
  end

  test "can't send an invite if the phone number is invalid" do
    post("/chat/invites", params: {
      invite: {
        phone_number: "333 (334) 320-4550"
      }
    })

    assert_response(:success)
    assert_present(flash.now[:alert])
    assert_blank(cookies[:chat_invite_sid])
    assert_blank(cookies[:chat_invite_phone_number])
  end

  # -- create/helpers
  def request_invite!(chat_rec)
    VCR.use_cassette("chats--request-invite") do
      post("/chat/invites", params: {
        invite: {
          phone_number: number_to_phone(chat_rec.recipient.phone_number)
        }
      })
    end
  end

  # -- edit --
  test "views prompt to verify an invite" do
    chat_rec = chats(:idle_1)
    request_invite!(chat_rec)

    get("/chat/invites/verify")
    assert_response(:success)
  end

  test "can't view prompt to verify an unrequested invite" do
    get("/chat/invites/verify")
    assert_redirected_to("/chat/invites/new")
  end

  # -- update --
  test "starts a session" do
    chat_rec = chats(:idle_1)
    request_invite!(chat_rec)

    act = -> do
      VCR.use_cassette("chats--verify-invite") do
        patch("/chat/invites", params: {
          invite: {
            code: "8842"
          }
        })
      end
    end

    assert_changes(
      -> { chat_rec.reload.session_token },
      &act
    )

    assert_redirected_to("/chat")
    assert_present(cookies[:chat_session_token])
    assert_blank(cookies[:chat_invite_sid])
    assert_blank(cookies[:chat_invite_phone_number])
  end

  test "can't start a session with an unrequested invite" do
    patch("/chat/invites", params: {
      invite: {
        code: "4039"
      }
    })

    assert_redirected_to("/chat/invites/new")
  end

  test "can't start a session with an incorrect invite" do
    chat_rec = chats(:idle_1)
    request_invite!(chat_rec)

    VCR.use_cassette("chats--verify-invite--invalid") do
      patch("/chat/invites", params: {
        invite: {
          code: "9999"
        }
      })
    end

    assert_response(:success)
    assert_present(flash.now[:alert])
    assert_not_nil(cookies[:chat_invite_sid])
    assert_not_nil(cookies[:chat_invite_phone_number])
  end
end
