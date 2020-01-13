module Cases
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

      kase.add_mms_message(message)
      @case_repo.save_new_message(kase)
    end
  end
end
