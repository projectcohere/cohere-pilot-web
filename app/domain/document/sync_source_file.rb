class Document
  class SyncSourceFile
    def initialize(
      download_file:,
      document_repo: Repo.new
    )
      @download_file = download_file
      @document_repo = document_repo
    end

    # -- command --
    def call(document_id)
      @document = @document_repo.find(document_id)
      file = @download_file.(@document.source_url)
      @document.attach_file(file)
      @document_repo.save_attached_file(@document)
    end
  end
end
