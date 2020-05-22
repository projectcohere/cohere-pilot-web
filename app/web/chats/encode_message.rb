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
        m.status.index,
        m.timestamp,
        m.attachments.map(&:file).compact.map { |f|
          Attachment.new(
            f.filename,
            f.service_url,
            transform_preview_url(f),
          )
        }
      )
    end

    private def transform_preview_url(f)
      if not f.representable?
        return nil
      end

      return f.representation(resize: "400x400>").processed.service_url
    rescue ActiveStorage::FileNotFoundError => e
      # TODO: we should not be catching (or even encountering) this error?, but not sure
      # how to make sure ActiveStorage::Blob fixtures to exist in dev (copying the files
      # into ./tmp/storage does not seem to cut it?)
      if not Rails.env.development?
        raise e
      end

      return f.service_url
    end
  end
end
