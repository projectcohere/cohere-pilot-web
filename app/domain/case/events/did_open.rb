class Case
  module Events
    class DidOpen < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_program)
      prop(:case_is_referral)
      props_end!

      # -- factories --
      def self.from_entity(kase)
        DidOpen.new(
          case_id: kase.id,
          case_program: kase.program,
          case_is_referral: kase.referral?
        )
      end
    end
  end
end
