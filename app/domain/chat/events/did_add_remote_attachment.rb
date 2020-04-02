class Chat
  module Events
    class DidAddRemoteAttachment < ::Value
      # -- props --
      prop(:attachment_id)

      # -- factories --
      def self.from_entity(attachment)
        return DidAddRemoteAttachment.new(
          attachment_id: attachment.id,
        )
      end
    end
  end
end
