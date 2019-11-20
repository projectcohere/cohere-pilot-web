class Case
  module Events
    class DidReceiveFirstMessage < ::Value
      # -- props --
      prop(:case_id)
      props_end!

      # -- factories --
      def self.from_entity(kase)
        DidReceiveFirstMessage.new(
          case_id: kase.id
        )
      end
    end
  end
end
