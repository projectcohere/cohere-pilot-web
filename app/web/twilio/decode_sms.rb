module Twilio
  class DecodeSms < ::Command
    def call(params)
      message = Sms::Message.new(
        phone_number: params["From"]&.delete_prefix("+1"),
        body: params["Body"],
        media: decode_media(params),
      )

      return message
    end

    # -- command/helpers
    private def decode_media(params)
      count = params["NumMedia"]&.to_i
      if count == nil || count == 0
        return []
      end

      return (0...count).map do |i|
        Sms::Media.new(url: params["MediaUrl#{i}"])
      end
    end
  end
end
