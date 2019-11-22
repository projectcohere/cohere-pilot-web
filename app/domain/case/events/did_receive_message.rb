class Case
  module Events
    class DidReceiveMessage < ::Value
      # -- props --
      prop(:case_id)
      props_end!

      # -- factories --
      def self.from_entity(kase)
        DidReceiveMessage.new(
          case_id: kase.id
        )
      end
    end
  end
end
