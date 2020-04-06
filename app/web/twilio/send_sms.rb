module Twilio
  class SendSms < ::Command
    include ::Logging

    # -- lifetime --
    def initialize(twilio: Client.get)
      @twilio = twilio
    end

    # -- command --
    def call(phone_number, body:, media_urls:)
      @twilio.post("/Messages.json", {
        "To" => "+1#{phone_number}",
        "From" => ENV["TWILIO_API_PHONE_NUMBER"],
        "Body" => body,
        "MediaUrl" => media_urls,
        "StatusCallback" => "#{ENV["HOST"]}/chats/sms/status",
      })

      return nil
    end
  end
end
