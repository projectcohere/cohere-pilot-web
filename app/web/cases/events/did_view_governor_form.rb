module Cases
  module Events
    class DidViewGovernorForm < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_program)
      prop(:case_is_referred)

      # -- factories --
      def self.from_entity(kase)
        DidViewGovernorForm.new(
          case_id: kase.id,
          case_program: kase.program,
          case_is_referred: kase.referral?
        )
      end
    end
  end
end