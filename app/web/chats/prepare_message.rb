module Chats
  class PrepareMessage < ApplicationWorker
    sidekiq_options(lock: :until_executed)

    # -- lifetime --
    def initialize(chat_repo: Chat::Repo.get)
      @chat_repo = chat_repo
    end

    ## -- command --
    def call(message_id)
      chat = @chat_repo.find_by_message_with_attachments(message_id)
      chat.prepare_message
      @chat_repo.save_prepared_message(chat)
    end
  end
end
