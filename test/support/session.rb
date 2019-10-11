require "clearance/testing/deny_access_matcher"

module Support
  module Session
    # -- commands --
    def sign_in(user = users(:cohere_1))
      # all the fixtures are gonna use password
      user.password = "password"

      # make the sign-in request
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
  end
end

ActionDispatch::IntegrationTest.include(Support::Session)
