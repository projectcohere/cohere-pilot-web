class Case
  module Events
    class DidReceiveMessage < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_program)
      prop(:case_is_referred)
      prop(:is_first)
      props_end!

      # -- factories --
      def self.from_entity(kase)
        DidReceiveMessage.new(
          case_id: kase.id,
          case_program: kase.program,
          case_is_referred: kase.referral?,
          is_first: kase.received_message_at.nil?
        )
      end
    end
  end
end
