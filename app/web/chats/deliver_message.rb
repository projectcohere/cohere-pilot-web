module Chats
  class DeliverMessage < ApplicationWorker
    def initialize(chat_message_repo: Chat::Message::Repo.get)
      @chat_message_repo = chat_message_repo
    end

    def call(chat_message_id)
      chat_message = @chat_message_repo.find(chat_message_id)

      Chats::Channel.broadcast_to(chat_message.chat_id, {
        sender: chat_message.sender,
        message: {
          body: chat_message.body,
        },
      })
    end

    alias :perform :call
  end
end
