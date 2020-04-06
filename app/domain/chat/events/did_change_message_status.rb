class Chat
  module Events
    class DidChangeMessageStatus < ::Value
      # -- props --
      prop(:message_id)

      # -- factories --
      def self.from_entity(message)
        return DidChangeMessageStatus.new(
          message_id: message.id,
        )
      end
    end
  end
end
