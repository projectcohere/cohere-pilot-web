require "clearance/testing/deny_access_matcher"

module Support
  module Sessions
    # -- commands --
    def sign_in(user = default_user)
      if user.password.nil?
        raise "user must have a plaintext password"
      end

      post(session_path, params: {
        session: {
          email: user.email,
          password: user.password
        }
      })
    end

    # -- queries--
    def current_session
      @controller.request.env[:clearance]
    end

    def current_user
      @current_session.current_user
    end

    def default_user
      u = User.first
      u.password = "password"
      u
    end
  end
end

ActionDispatch::IntegrationTest.include(Support::Sessions)
