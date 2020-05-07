module Cases
  module Events
    class DidSaveGovernorForm < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_program)

      # -- factories --
      def self.from_entity(kase)
        DidSaveGovernorForm.new(
          case_id: kase.id,
          case_program: kase.program,
        )
      end
    end
  end
end
