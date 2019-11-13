module Cases
  class AttachContractWorker < ApplicationWorker
    def perform(case_id, document_id)
      attach_file = AttachDocumentFile.new(
        generate_file: GenerateContract.new
      )

      attach_file.(case_id, document_id)
    end
  end
end
