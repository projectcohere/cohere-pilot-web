module Cases
  class AddMmsMessage
    # -- lifetime --
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(message)
      kase = find_case_by_message(message)
      kase.add_mms_message(message)
      @case_repo.save_new_message(kase)
    end

    # -- command/helpers
    private def find_case_by_message(message)
      kase = @case_repo.find_by_phone_number(message.sender.phone_number)
      if kase.nil?
        raise "No case found for phone number #{message.sender.phone_number}"
      end

      return kase
    end
  end
end
