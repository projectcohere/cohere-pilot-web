require "test_helper"

class SessionsTests < ActionDispatch::IntegrationTest
  test "can start a session" do
    post("/session", params: {
      session: {
        email: "test@cohere.com",
        password: "password"
      }
    })

    assert_response(:redirect)
    assert(current_session.signed_in?)
  end

  test "can end a session" do
    sign_in
    delete("/session")
    assert_response(:redirect)
    assert(current_session.signed_out?)
  end
end
