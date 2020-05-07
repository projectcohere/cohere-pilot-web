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
      chat = @chat_repo.find_by_message_with_attachments(chat_message_id)
      kase = @case_repo.find_by_chat_recipient(chat.recipient.id)

      # if there's no case attach to, ignore this message
      if kase == nil
        return
      end

      kase.add_chat_message(chat.selected_message)
      @case_repo.save_new_message(kase)
    end
  end
end
