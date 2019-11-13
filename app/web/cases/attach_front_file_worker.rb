module Cases
  class AttachFrontFileWorker < ApplicationWorker
    def perform(case_id, document_id)
      attach_file = AttachDocumentFile.new(
        generate_file: Front::DownloadAttachment.new
      )

      attach_file.(case_id, document_id)
    end
  end
end
