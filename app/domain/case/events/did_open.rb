class Case
  module Events
    class DidOpen < ::Value
      # -- props --
      prop(:temp_id)
      prop(:case_id)
      prop(:case_recipient_id)
      prop(:case_recipient_phone_number)
      prop(:case_program)
      prop(:case_is_referred)

      # -- factories --
      def self.from_entity(kase, temp_id:)
        DidOpen.new(
          temp_id: temp_id,
          case_id: kase.id,
          case_recipient_id: kase.recipient.id,
          case_recipient_phone_number: kase.recipient.profile.phone.number,
          case_program: kase.program,
          case_is_referred: kase.referred?
        )
      end
    end
  end
end
