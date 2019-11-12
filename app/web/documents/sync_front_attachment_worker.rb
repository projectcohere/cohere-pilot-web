module Documents
  class SyncFrontAttachmentWorker < ApplicationWorker
    def perform(document_id)
      sync_source_file = Document::SyncSourceFile.new(
        download_file: Front::DownloadAttachment.new
      )

      sync_source_file.(document_id)
    end
  end
end
