class Case
  module Events
    class DidOpen < ::Value
      # -- props --
      prop(:case_id)
      props_end!

      # -- factories --
      def self.from_case(kase)
        DidOpen.new(
          case_id: kase.id
        )
      end
    end
  end
end
