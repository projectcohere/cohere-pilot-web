class Case
  module Events
    class DidUploadMessageAttachment < ::Value
      # -- props --
      prop(:case_id)
      prop(:document_id)

      # -- factories --
      def self.from_entity(kase, document)
        DidUploadMessageAttachment.new(
          case_id: kase.id,
          document_id: document.id
        )
      end
    end
  end
end
