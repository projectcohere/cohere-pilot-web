module Front
  class DecodeMessage
    # -- command --
    def call(json_string)
      json = ActiveSupport::JSON.decode(json_string)
      json["target"]["data"].then { |json|
        Sms::Message.new(
          phone_number: decode_phone_number(json, "from"),
          attachments: decode_attachments(json),
        )
      }
    end

    # -- command/helpers
    private def decode_phone_number(json, role)
      phone_number = json["recipients"]
        .find { |j| j["role"] == role }
        .dig("handle")

      return phone_number.delete_prefix("+1")
    end

    private def decode_attachments(json)
      json = json["attachments"]
      json.map do |j|
        Sms::Media.new(url: j["url"])
      end
    end
  end
end
