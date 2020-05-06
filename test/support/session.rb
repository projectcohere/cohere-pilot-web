require "clearance/testing/deny_access_matcher"

module Support
  module Session
    # -- commands --
    def auth(url, as: users(:agent_1))
      as_user = as
      as_param = "as=#{as_user.id}"

      if url.include?("?")
        "#{url}&#{as_param}"
      else
        "#{url}?#{as_param}"
      end
    end

    # -- queries--
    def current_session
      @controller.request.env[:clearance]
    end
  end
end

ActionDispatch::IntegrationTest.include(Support::Session)
