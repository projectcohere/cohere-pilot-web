module Chats
  class StartSession < ::Command
    # -- lifetime --
    def initialize(chat_repo: Chat::Repo.get)
      @chat_repo = chat_repo
    end

    # -- comamnd --
    def call(phone_number)
      chat = @chat_repo.find_by_phone_number(phone_number)
      if chat == nil
        return nil
      end

      chat.start_session
      @chat_repo.save_new_session(chat)

      return chat.session
    end
  end
end
