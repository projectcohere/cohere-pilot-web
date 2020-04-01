module Twilio
  class DecodeSms < ::Command
    def call(params)
      message = Sms::Message.new(
        phone_number: decode_phone_number(params),
        attachments: decode_attachments(params),
      )

      return message
    end

    # -- command/helpers
    private def decode_phone_number(params)
      return params["From"]&.delete_prefix("+1")
    end

    private def decode_attachments(params)
      count = params["NumMedia"]&.to_i
      if count == nil || count == 0
        return []
      end

      if count == 1
        return [
          Sms::Attachment.new(url: params["MediaUrl"])
        ]
      end

      return (0...count).map do |i|
        Sms::Attachment.new(url: params["MediaUrl#{i}"])
      end
    end
  end
end
