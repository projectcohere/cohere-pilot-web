class Case
  class UploadMessageAttachments
    # -- lifetime --
    def initialize(
      decode_message:,
      case_repo: Case::Repo.get
    )
      @decode_message = decode_message
      @case_repo = case_repo
    end

    # -- command --
    def call(data)
      message = @decode_message.(data)
      message_phone_number = message.sender.phone_number

      kase = @case_repo.find_by_phone_number(message_phone_number)
      if kase.nil?
        raise "No case found for phone number #{message_phone_number}"
      end

      kase.upload_message_attachments(message)
      @case_repo.save_new_documents(kase)

      kase.new_documents
    end
  end
end
