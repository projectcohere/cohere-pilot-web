class Case
  module Events
    class DidReceiveMessage < ::Value
      # -- props --
      prop(:case_id)
      prop(:is_first)
      props_end!

      # -- factories --
      def self.from_entity(kase)
        DidReceiveMessage.new(
          case_id: kase.id,
          is_first: kase.received_message_at.nil?
        )
      end
    end
  end
end
