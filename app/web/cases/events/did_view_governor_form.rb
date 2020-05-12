module Cases
  module Events
    class DidViewGovernorForm < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_program)

      # -- factories --
      def self.from_entity(kase)
        DidViewGovernorForm.new(
          case_id: kase.id,
          case_program: kase.program,
        )
      end
    end
  end
end
