class Message
  class DecodeFrontJson
    # -- command --
    def call(json_string)
      json = ActiveSupport::JSON.decode(json_string)
      json["target"]["data"].then { |json|
        Message.new(
          sender: decode_sender(json),
          attachments: decode_attachments(json)
        )
      }
    end

    # -- command/helpers
    private def decode_sender(json)
      json = json["recipients"]
        .find { |j| j["role"] == "from" }

      Sender::new(
        phone_number: json["handle"]
      )
    end

    private def decode_attachments(json)
      json = json["attachments"]
      json.map do |j|
        Attachment.new(url: j["url"])
      end
    end
  end
end
