require "net/http"

module Chats
  class SendInvite < ::Command
    # -- liftime --
    def initialize(twilio: Twilio.get, chat_repo: Chat::Repo.get)
      @twilio = twilio
      @chat_repo = chat_repo
    end

    # -- command --
    def call(phone_number)
      chat = @chat_repo.find_or_create_by_phone_number(phone_number)
      if chat == nil
        # TODO: differentiate between error states (missing chat vs request failure)
        return nil
      end

      json = @twilio.post("/Verifications", {
        "To" => "+1#{phone_number}",
        "Channel" => "sms",
      })

      return json&.dig("sid")
    end
  end
end
