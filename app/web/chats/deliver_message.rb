module Chats
  class DeliverMessage < ApplicationWorker
    def initialize(chat_repo: Chat::Repo.get)
      @chat_repo = chat_repo
    end

    def call(chat_id, chat_message_id)
      chat = @chat_repo.find_with_message(chat_id, chat_message_id)

      Chats::Channel.broadcast_to(chat, {
        sender: chat.selected_message.sender,
        message: {
          type: chat.selected_message.type,
          body: chat.selected_message.body,
        },
      })
    end

    alias :perform :call
  end
end
