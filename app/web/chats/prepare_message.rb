module Chats
  class PrepareMessage < ApplicationWorker
    sidekiq_options(lock: :until_executed)

    # -- lifetime --
    def initialize(chat_repo: Chat::Repo.get)
      @chat_repo = chat_repo
    end

    ## -- command --
    def call(message_id)
      chat = @chat_repo.find_by_selected_message(message_id)
      chat.prepare_selected_message
      @chat_repo.save_prepared_message(chat)

      # TODO: extract into ApplicationWorker
      # TODO: since events run synchronously in tests, this tries to re-run events
      # Events::DispatchAll.()
    end

    alias :perform :call
  end
end
