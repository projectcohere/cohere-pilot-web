require "test_helper"

class SessionsTests < ActionDispatch::IntegrationTest
  test "can view the sign in page" do
    get("/sign-in")
    assert(:success)
  end

  test "can sign in as an operator" do
    post("/session", params: {
      session: {
        email: "me@cohere.com",
        password: "password"
      }
    })

    assert(current_session.signed_in?)
    assert_redirected_to("/cases")
  end

  test "can sign in as an enroller" do
    post("/session", params: {
      session: {
        email: "me@testmetro.com",
        password: "password"
      }
    })

    assert(current_session.signed_in?)
    assert_redirected_to("/cases")
  end

  test "can sign in as a supplier" do
    post("/session", params: {
      session: {
        email: "me@testenergy.com",
        password: "password"
      }
    })

    assert(current_session.signed_in?)
    assert_redirected_to("/cases/inbound")
  end

  test "can sign in as a dhs partner" do
    post("/session", params: {
      session: {
        email: "me@dhs.gov",
        password: "password"
      }
    })

    assert(current_session.signed_in?)
    assert_redirected_to("/cases/opened")
  end

  test "can sign out" do
    delete(auth("/sign-out"))
    assert_response(:redirect)
    assert(current_session.signed_out?)
  end
end
