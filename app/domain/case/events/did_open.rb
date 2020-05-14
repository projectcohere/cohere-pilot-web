class Case
  module Events
    class DidOpen < ::Value
      # -- props --
      prop(:temp_id)
      prop(:case_id)
      prop(:case_recipient_id)
      prop(:case_recipient_phone_number)
      prop(:case_program)

      # -- factories --
      def self.from_entity(kase, temp_id:)
        DidOpen.new(
          temp_id: temp_id,
          case_id: kase.id,
          case_recipient_id: kase.recipient.id,
          case_recipient_phone_number: kase.recipient.profile.phone.number,
          case_program: kase.program,
        )
      end
    end
  end
end
