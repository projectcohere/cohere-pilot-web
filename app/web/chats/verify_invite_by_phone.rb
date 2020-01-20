module Chats
  class VerifyInviteByPhone < ::Command
    # -- lifetime --
    def initialize(twilio: Twilio.get)
      @twilio = twilio
    end

    # -- command --
    def call(phone_number, code)
      json = @twilio.post("/VerificationCheck", {
        "To" => "+1#{phone_number}",
        "Code" => code,
      })

      return json&.dig("status") == "approved"
    end
  end
end
