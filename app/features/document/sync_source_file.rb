class Document
  class SyncSourceFile
    def initialize(
      download_file:,
      documents: Repo.new
    )
      @download_file = download_file
      @documents = documents
    end

    # -- command --
    def call(document_id)
      @document = @documents.find(document_id)
      file = @download_file.(@document.source_url)
      @document.attach_file(file)
      @documents.save_attached_file(@document)
    end
  end
end
