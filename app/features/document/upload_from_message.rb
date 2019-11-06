class Document
  class UploadFromMessage
    # -- lifetime --
    def initialize(
      decode_message:,
      case_repo: Case::Repo.get,
      document_repo: Document::Repo.get
    )
      @decode_message = decode_message
      @case_repo = case_repo
      @document_repo = document_repo
    end

    # -- command --
    def call(data)
      message = @decode_message.(data)
      message_phone_number = message.sender.phone_number

      kase = @case_repo.find_by_phone_number(message_phone_number)
      if kase.nil?
        raise "No case found for phone number #{message_phone_number}"
      end

      new_documents = kase.upload_documents_from_message(message)
      @document_repo.save_uploaded(new_documents)

      new_documents
    end
  end
end
