module Chats
  class PublishMessageStatus < ApplicationWorker
    # -- lifetime --
    def initialize(message_repo: Chat::Message::Repo.get)
      @message_repo = message_repo
    end

    # -- command --
    def call(message_id)
      message = @message_repo.find_with_attachments(message_id)
      MessagesChannel.broadcast_to(
        message.chat_id,
        MessagesEvent.has_new_status(message),
      )
    end
  end
end
