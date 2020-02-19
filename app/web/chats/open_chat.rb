module Chats
  class OpenChat < ::Command
    # -- lifetime --
    def initialize(chat_repo: Chat::Repo.get)
      @chat_repo = chat_repo
    end

    # -- commands --
    def call(recipient_id)
      if @chat_repo.any_by_recipient?(recipient_id)
        return
      end

      chat_recipient = @chat_repo.find_chat_recipient(recipient_id)
      chat = Chat.open(chat_recipient)

      @chat_repo.save_opened(chat)
    end
  end
end
