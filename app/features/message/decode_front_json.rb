class Message
  class DecodeFrontJson
    def call(json_string)
      decode_message(ActiveSupport::JSON.decode(json_string))
    end

    private def decode_message(json)
      Message.new(
        recipient: decode_recipient(json)
      )
    end

    private def decode_recipient(json)
      json = json
        .dig("target", "data", "recipients")
        .find { |j| j["role"] == "from" }

      Recipient::new(
        phone_number: json["handle"]
      )
    end
  end
end
