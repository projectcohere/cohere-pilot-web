class Case
  module Events
    class DidComplete < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_status)
      props_end!

      # -- factories --
      def self.from_entity(kase)
        DidComplete.new(
          case_id: kase.id,
          case_status: kase.status
        )
      end
    end
  end
end
