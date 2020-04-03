class Chat
  module Events
    class DidUploadAttachment < ::Value
      # -- props --
      prop(:message_id)
      prop(:attachment_url)

      # -- factories --
      def self.from_entity(chat)
        m = chat.selected_message
        a = chat.selected_attachment

        return DidUploadAttachment.new(
          message_id: m.id,
          attachment_url: a.uploaded_url,
        )
      end
    end
  end
end
