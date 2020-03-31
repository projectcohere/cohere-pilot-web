class Chat
  module Events
    class DidAddMessage < ::Value
      # -- props --
      prop(:chat_message_id)
      prop(:chat_message_sent_by_recipient)

      # -- factories --
      def self.from_entity(chat)
        message = chat.new_message

        return DidAddMessage.new(
          chat_message_id: message.id,
          chat_message_sent_by_recipient: message.sent_by_recipient?,
        )
      end
    end
  end
end
