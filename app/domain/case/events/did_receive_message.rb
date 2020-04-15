class Case
  module Events
    class DidReceiveMessage < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_program)
      prop(:case_is_referred)
      prop(:is_first)

      # -- factories --
      def self.from_entity(kase, is_first:)
        DidReceiveMessage.new(
          case_id: kase.id,
          case_program: kase.program,
          case_is_referred: kase.referred?,
          is_first: is_first,
        )
      end
    end
  end
end
