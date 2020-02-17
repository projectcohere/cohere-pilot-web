module Chats
  class DeliverReminder < ApplicationWorker
    sidekiq_options(
      lock: :until_executed
    )

    # -- lifetime --
    def initialize(chat_repo: Chat::Repo.get)
      @chat_repo = chat_repo
    end

    ## -- command --
    def call(chat_id)
      chat = @chat_repo.find(chat_id)

      # short-circuit if the recipient read the chat in the meantime
      conversation = chat.sms_conversation
      if not conversation.reminder?
        return
      end

      raise "unimplemented"
    end

    alias :perform :call
  end
end
