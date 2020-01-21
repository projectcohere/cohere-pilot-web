class Case
  module Events
    class DidOpen < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_recipient_id)
      prop(:case_recipient_phone_number)
      prop(:case_program)
      prop(:case_is_referred)
      props_end!

      # -- factories --
      def self.from_entity(kase)
        DidOpen.new(
          case_id: kase.id,
          case_recipient_id: kase.recipient.id,
          case_recipient_phone_number: kase.recipient.profile.phone.number,
          case_program: kase.program,
          case_is_referred: kase.referral?
        )
      end
    end
  end
end
