module Chats
  class VerifyInviteById < ::Command
    # -- lifetime --
    def initialize(twilio: Twilio.get)
      @twilio = twilio
    end

    # -- command --
    def call(id, code)
      json = @twilio.post("/VerificationCheck", {
        "VerificationSid" => id,
        "Code" => code,
      })

      return json&.dig("status") == "approved"
    end
  end
end
