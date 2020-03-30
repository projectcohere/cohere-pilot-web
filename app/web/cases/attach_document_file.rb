module Cases
  # TODO: maybe this is more of an application service
  class AttachDocumentFile
    def initialize(
      generate_file:,
      case_repo: Case::Repo.new
    )
      @generate_file = generate_file
      @case_repo = case_repo
    end

    # -- command --
    def call(case_id, document_id)
      @case = @case_repo.find_with_document(case_id, document_id)

      file = @generate_file.(@case)
      @case.attach_file_to_selected_document(file)

      @case_repo.save_selected_attachment(@case)
    end
  end
end
