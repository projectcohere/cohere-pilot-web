module Cases
  class AttachFile < ::Command
    # -- lifetime --
    def initialize(
      generate:,
      case_repo: Case::Repo.new
    )
      @generate = generate
      @case_repo = case_repo
    end

    # -- command --
    def call(case_id, document_id)
      @case = @case_repo.find_with_document(case_id, document_id)
      file = @generate.(@case)
      @case.attach_file_to_selected_document(file)
      @case_repo.save_selected_attachment(@case)
    end
  end
end
