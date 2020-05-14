class Case
  module Events
    class DidReceiveMessage < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_program)
      prop(:is_first)

      # -- factories --
      def self.from_entity(kase, is_first:)
        DidReceiveMessage.new(
          case_id: kase.id,
          case_program: kase.program,
          is_first: is_first,
        )
      end
    end
  end
end
