module Cases
  class AttachContractWorker < ApplicationWorker
    # -- command --
    def perform(case_id, document_id)
      attach_file = AttachDocumentFile.new(
        generate_file: GenerateContractPdf.new
      )

      attach_file.(case_id, document_id)
    end
  end
end
