class Case
  module Events
    class DidSubmit < ::Value
      # -- props --
      prop(:case_id)
      props_end!

      # -- factories --
      def self.from_entity(kase)
        DidSubmit.new(
          case_id: kase.id
        )
      end
    end
  end
end
