module Cases
  class AddSmsMessage < ::Command
    # -- lifetime --
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(message)
      kase = @case_repo.find_by_phone_number(message.phone_number)
      if kase.nil?
        raise "No case found for phone number #{message.phone_number}"
      end

      kase.add_sms_message(message)
      @case_repo.save_new_message(kase)
    end
  end
end
