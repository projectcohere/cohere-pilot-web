require "test_helper"

class UsersTests < ActionDispatch::IntegrationTest
  # -- sign-in --
  test "views the sign in page" do
    get("/sign-in")
    assert_response(:success)
    assert_select(".SignIn-title h2", text: /sign in/)
  end

  test "signs in as an operator" do
    session_params = {
      session: {
        email: "me@cohere.org",
        password: "password"
      }
    }

    post("/sessions", params: session_params)
    assert(current_session.signed_in?)
    assert_redirected_to("/cases")
  end

  test "signs in as an enroller" do
    session_params = {
      session: {
        email: "me@testmetro.org",
        password: "password"
      }
    }

    post("/sessions", params: session_params)
    assert(current_session.signed_in?)
    assert_redirected_to("/cases/enroller")
  end

  test "signs in as a supplier" do
    session_params = {
      session: {
        email: "me@testenergy.com",
        password: "password"
      }
    }

    post("/sessions", params: session_params)
    assert(current_session.signed_in?)
    assert_redirected_to("/cases/supplier")
  end

  test "signs in as a dhs partner" do
    session_params = {
      session: {
        email: "me@michigan.gov",
        password: "password"
      }
    }

    post("/sessions", params: session_params)
    assert(current_session.signed_in?)
    assert_redirected_to("/cases/dhs")
  end

  # -- sign-out --
  test "signs out" do
    delete(auth("/sign-out"))
    assert_response(:redirect)
    assert(current_session.signed_out?)
  end

  # -- reset-password --
  test "views the forgot password page" do
    get("/passwords/forgot")
    assert_response(:success)
    assert_select(".SignIn-title h1", text: "Forgot Your Password?")
  end

  test "sends a password reset email" do
    user_rec = users(:cohere_1)
    password_params = {
      password: {
        email: user_rec.email
      }
    }

    post("/passwords", params: password_params)
    assert_response(:success)

    send_all_emails!
    assert_emails(1)
    assert_select_email do
      assert_select("a", text: /Change my password/) do |el|
        assert_match(%r[#{ENV["HOST"]}/user/\d+/password/edit], el[0][:href])
      end
    end
  end

  test "does not send a password reset email for a missing user" do
    password_params = {
      password: {
        email: "fake@website.com"
      }
    }

    post("/passwords", params: password_params)
    assert_response(:success)

    send_all_emails!
    assert_emails(0)
  end

  test "follows the reset password link" do
    user_rec = users(:cohere_1)
    user_rec.forgot_password! # this generates a confirmation token
    reset_params = {
      token: user_rec.confirmation_token
    }

    get("/user/#{user_rec.id}/password/edit", params: reset_params)
    assert_redirected_to("/user/#{user_rec.id}/password/edit")

    get("/user/#{user_rec.id}/password/edit")
    assert_response(:success)
    assert_select(".SignIn-title h1", text: "Reset Your Password")
  end

  test "can't view the reset password page if it wasn't requested" do
    user_rec = users(:cohere_1)

    get("/user/#{user_rec.id}/password/edit", params: { token: nil })
    assert_response(:success)
    assert_select(".SignIn-title h1", text: "Forgot Your Password?")
  end

  test "resets the password" do
    user_rec = users(:cohere_1)
    user_rec.forgot_password! # this generates a confirmation token

    reset_params = {
      token: user_rec.confirmation_token,
      password_reset: {
        password: "test-password"
      }
    }

    patch("/user/#{user_rec.id}/password", params: reset_params)
    assert_redirected_to(root_path)
  end

  # -- invitation --
  test "invites the user" do
    event_queue = EventQueue.new
    invite_user = Users::InviteUser.new(
      user_repo: User::Repo.new(
        event_queue: event_queue
      ),
      process_events: Events::ProcessAll.new(
        event_queue: event_queue
      )
    )

    invite_user.("test@cohere.org",
      role: User::Role.named(:cohere)
    )

    send_all_emails!
    assert_emails(1)
    assert_select_email do
      assert_select("a", text: /create a password/) do |el|
        assert_match(%r[#{ENV["HOST"]}/user/\d+/password/edit\?invited=true&token=\w+], el[0][:href])
      end
    end
  end

  test "follows the create password link" do
    user_rec = users(:cohere_1)
    user_rec.forgot_password! # this generates a confirmation token
    reset_params = {
      token: user_rec.confirmation_token,
      invited: true
    }

    get("/user/#{user_rec.id}/password/edit", params: reset_params)
    assert_redirected_to("/user/#{user_rec.id}/password/edit")

    get("/user/#{user_rec.id}/password/edit")
    assert_response(:success)
    assert_select(".SignIn-title h1", text: "Create Your Password")
  end
end
