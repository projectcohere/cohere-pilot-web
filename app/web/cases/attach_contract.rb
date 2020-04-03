module Cases
  class AttachContract < ApplicationWorker
    # -- lifetime --
    def initialize(case_repo: Case::Repo.new)
      @case_repo = case_repo
    end

    # -- command --
    def call(case_id, document_id)
      @case = @case_repo.find_with_document(case_id, document_id)
      @case.attach_file_to_selected_document(GenerateContract.(@case))
      @case_repo.save_selected_document(@case)
    end

    alias :perform :call
  end
end
