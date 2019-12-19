class Chat
  module Events
    class DidReceiveMessage < ::Value
      # -- props --
      prop(:chat_id)
      prop(:chat_message_id)
      props_end!

      # -- factories --
      def self.from_entity(chat)
        DidReceiveMessage.new(
          chat_id: chat.id,
          chat_message_id: chat.new_messages.last.id
        )
      end
    end
  end
end
