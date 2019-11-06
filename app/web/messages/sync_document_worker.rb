module Messages
  class SyncDocumentWorker < ApplicationWorker
    def perform(document_id)
      sync_source_file = Document::SyncSourceFile.new(
        download_file: Front::DownloadAttachment.new
      )

      sync_source_file.call(document_id)
    end
  end
end
