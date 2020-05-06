module Twilio
  class SendSms < ::Command
    include ::Logging

    # -- lifetime --
    def initialize(decode: DecodeSms.get, twilio: Client.get)
      @decode = decode
      @twilio = twilio
    end

    # -- command --
    def call(phone_number, body:, media_urls:)
      res = @twilio.post("/Messages.json", {
        "To" => "+1#{phone_number}",
        "From" => ENV["TWILIO_API_PHONE_NUMBER"],
        "Body" => body,
        "MediaUrl" => media_urls,
        "StatusCallback" => "#{ENV["HOST"]}/chats/sms/status",
      })

      if not res.success?
        return nil
      end

      return @decode.(res.json)
    end
  end
end
