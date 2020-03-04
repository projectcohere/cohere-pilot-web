module Front
  class DecodeMessage
    # -- command --
    def call(json_string)
      json = ActiveSupport::JSON.decode(json_string)
      json["target"]["data"].then { |json|
        Mms::Message.new(
          sender: decode_sender(json),
          attachments: decode_attachments(json)
        )
      }
    end

    # -- command/helpers
    private def decode_sender(json)
      json = json["recipients"]
        .find { |j| j["role"] == "from" }

      Mms::Sender::new(
        phone_number: json["handle"].delete_prefix("+1")
      )
    end

    private def decode_attachments(json)
      json = json["attachments"]
      json.map do |j|
        Mms::Attachment.new(url: j["url"])
      end
    end
  end
end
