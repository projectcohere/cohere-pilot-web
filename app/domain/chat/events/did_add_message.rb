class Chat
  module Events
    class DidAddMessage < ::Value
      # -- props --
      prop(:chat_message_id)

      # -- factories --
      def self.from_entity(chat)
        message = chat.new_message

        return DidAddMessage.new(
          chat_message_id: message.id,
        )
      end
    end
  end
end
