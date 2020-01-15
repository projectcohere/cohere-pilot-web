module Chats
  class OpenChat < ::Command
    # -- lifetime --
    def initialize(chat_repo: Chat::Repo.get)
      @chat_repo = chat_repo
    end

    # -- commands --
    def call(recipient_id)
      chat = Chat.open(recipient_id)
      @chat_repo.save_opened(chat)
    end
  end
end
