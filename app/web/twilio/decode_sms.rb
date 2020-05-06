module Twilio
  class DecodeSms < ::Command
    def call(params)
      return Sms::Message.new(
        id: decode_id(params),
        phone_number: params["From"]&.delete_prefix("+1"),
        body: params["Body"],
        media: decode_media(params),
        status: decode_status(params),
      )
    end

    # -- command/helpers
    private def decode_id(params)
      return params["SmsSid"] || params["sid"]
    end

    private def decode_status(params)
      return params["SmsStatus"] || params["status"]
    end

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
