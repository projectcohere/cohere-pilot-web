class Chat
  module Events
    class DidPrepareMessage < ::Value
      # -- props --
      prop(:message_id)
      prop(:message_sender)

      # -- factories --
      def self.from_entity(message)
        return DidPrepareMessage.new(
          message_id: message.id,
          message_sender: message.sender,
        )
      end
    end
  end
end
