class Case
  module Events
    class DidComplete < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_status)
      prop(:case_program)

      # -- factories --
      def self.from_entity(kase)
        DidComplete.new(
          case_id: kase.id,
          case_status: kase.status,
          case_program: kase.program,
        )
      end
    end
  end
end
