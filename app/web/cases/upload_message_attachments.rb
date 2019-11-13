module Cases
  # TODO: maybe this is more of an application service
  class UploadMessageAttachments
    # -- lifetime --
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(message)
      message_phone_number = message.sender.phone_number

      kase = @case_repo.find_by_phone_number(message_phone_number)
      if kase.nil?
        raise "No case found for phone number #{message_phone_number}"
      end

      kase.upload_message_attachments(message)
      @case_repo.save_new_documents(kase)
    end
  end
end
