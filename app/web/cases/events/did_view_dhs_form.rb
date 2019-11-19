module Cases
  module Events
    class DidViewDhsForm < ::Value
      # -- props --
      prop(:case_id)
      props_end!

      # -- factories --
      def self.from_entity(kase)
        DidViewDhsForm.new(
          case_id: kase.id
        )
      end
    end
  end
end
