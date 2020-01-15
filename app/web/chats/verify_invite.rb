module Chats
  class VerifyInvite < ::Command
    # -- lifetime --
    def initialize(twilio: Twilio.get)
      @twilio = twilio
    end

    # -- command --
    def call(sid, code)
      json = @twilio.post("/VerificationCheck", {
        "VerificationSid" => sid,
        "Code" => code,
      })

      return json&.dig("status") == "approved"
    end
  end
end
