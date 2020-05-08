class Case
  module Events
    class DidSubmitToEnroller < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_program)
      prop(:case_is_referred)

      # -- factories --
      def self.from_entity(kase)
        DidSubmitToEnroller.new(
          case_id: kase.id,
          case_program: kase.program,
          case_is_referred: kase.referred?
        )
      end
    end
  end
end