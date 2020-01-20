class Chat
  module Events
    class DidAddMessage < ::Value
      # -- props --
      prop(:chat_message_id)
      prop(:has_attachments)
      props_end!

      # -- factories --
      def self.from_entity(chat)
        message = chat.new_message
        DidAddMessage.new(
          chat_message_id: message.id,
          has_attachments: message.attachments.present?,
        )
      end
    end
  end
end