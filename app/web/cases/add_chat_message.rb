module Cases
  class AddChatMessage < ApplicationWorker
    # -- lifetime --
    def initialize(
      case_repo: Case::Repo.get,
      chat_repo: Chat::Repo.get
    )
      @case_repo = case_repo
      @chat_repo = chat_repo
    end

    # -- command --
    def call(chat_message_id)
      chat = @chat_repo.find_by_selected_message(chat_message_id)
      kase = @case_repo.find_active_by_recipient(chat.recipient.id)
      kase.add_chat_message(chat.selected_message)
      @case_repo.save_new_message(kase)
    end
  end
end
