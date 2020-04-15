class Case
  module Events
    class DidComplete < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_status)
      prop(:case_program)
      prop(:case_is_referred)

      # -- factories --
      def self.from_entity(kase)
        DidComplete.new(
          case_id: kase.id,
          case_status: kase.status,
          case_program: kase.program,
          case_is_referred: kase.referred?
        )
      end
    end
  end
end
