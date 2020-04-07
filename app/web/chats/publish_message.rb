module Chats
  class PublishMessage < ApplicationWorker
    # -- lifetime --
    def initialize(message_repo: Chat::Message::Repo.get)
      @message_repo = message_repo
    end

    # -- command --
    def call(message_id)
      Files::Host.set_current!

      message = @message_repo.find_with_attachments(message_id)
      MessagesChannel.broadcast_to(
        message.chat_id,
        MessagesEvent.did_add_message(message)
      )
    end
  end
end
