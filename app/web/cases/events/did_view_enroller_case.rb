module Cases
  module Events
    class DidViewEnrollerCase < ::Value
      # -- props --
      prop(:case_id)
      props_end!

      # -- factories --
      def self.from_entity(kase)
        DidViewEnrollerCase.new(
          case_id: kase.id
        )
      end
    end
  end
end
