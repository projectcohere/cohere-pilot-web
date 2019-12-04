class Case
  module Events
    class DidMakeReferral < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_program)
      props_end!

      # -- factories --
      def self.from_entity(kase, program:)
        DidMakeReferral.new(
          case_id: kase.id,
          case_program: program
        )
      end
    end
  end
end
