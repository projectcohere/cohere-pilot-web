class Case
  module Events
    class DidSubmitToEnroller < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_program)

      # -- factories --
      def self.from_entity(kase)
        DidSubmitToEnroller.new(
          case_id: kase.id,
          case_program: kase.program,
        )
      end
    end
  end
end
