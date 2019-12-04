class Case
  module Events
    class DidOpen < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_program)
      prop(:referring_case_id)
      props_end!

      # -- factories --
      def self.from_entity(kase, referring_case: nil)
        DidOpen.new(
          case_id: kase.id,
          case_program: kase.program,
          referring_case_id: referring_case&.id
        )
      end
    end
  end
end
