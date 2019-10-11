require "test_helper"

class SessionsTests < ActionDispatch::IntegrationTest
  test "can view the sign in page" do
    get("/sign-in")
    assert(:success)
  end

  test "can sign in" do
    post("/session", params: {
      session: {
        email: "test@cohere.com",
        password: "password"
      }
    })

    assert_response(:redirect)
    assert(current_session.signed_in?)
  end

  test "can sign out" do
    delete(auth("/sign-out"))
    assert_response(:redirect)
    assert(current_session.signed_out?)
  end
end
