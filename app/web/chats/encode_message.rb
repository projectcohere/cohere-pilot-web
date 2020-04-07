module Chats
  class EncodeMessage < ::Command
    # -- types --
    Message = Struct.new(
      :id,
      :sender,
      :body,
      :status,
      :timestamp,
      :attachments
    )

    Attachment = Struct.new(
      :name,
      :url,
      :preview_url
    )

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
      return Message.new(
        m.id.val,
        m.sender,
        m.body,
        m.timestamp,
        m.status.index,
        m.attachments.map { |a|
          if a.file == nil
            next nil
          end

          f = a.file
          Attachment.new(
            f.filename,
            f.service_url,
            f.representable? ? f.representation(resize: "400x400>").processed.service_url : nil
          )
        }
      )
    end
  end
end
