class Case
  module Events
    class DidSignContract < ::Value
      # -- props --
      prop(:case_id)
      prop(:document_id)
      props_end!

      # -- factories --
      def self.from_entity(kase, document)
        DidSignContract.new(
          case_id: kase.id,
          document_id: document.id
        )
      end
    end
  end
end
