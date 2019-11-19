class Case
  module Events
    class DidBecomePending < ::Value
      # -- props --
      prop(:case_id)
      props_end!

      # -- factories --
      def self.from_entity(kase)
        DidBecomePending.new(
          case_id: kase.id
        )
      end
    end
  end
end
