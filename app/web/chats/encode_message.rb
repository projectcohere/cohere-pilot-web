module Chats
  class EncodeMessage < ::Command
    # -- types --
    Envelope = Struct.new(
      :sender,
      :message
    )

    Message = Struct.new(
      :body,
      :timestamp,
      :attachments
    )

    Attachment = Struct.new(
      :name,
      :url,
      :previewUrl
    )

    # -- lifetime --
    def self.get
      EncodeMessage.new
    end

    # -- command --
    def call(message_or_messages)
      data = if message_or_messages.is_a?(Array)
        message_or_messages.map { |m| transform_message(m) }
      else
        transform_message(message_or_messages)
      end

      return data
    end

    # -- command/helpers
    private def transform_message(m)
      return Envelope.new(
        m.sender,
        Message.new(
          m.body,
          m.timestamp,
          m.attachments.map { |a|
            f = a.file
            Attachment.new(
              f.filename,
              f.service_url,
              f.representable? ? f.representation(resize: "400x400>").processed.service_url : nil
            )
          }
        )
      )
    end
  end
end
