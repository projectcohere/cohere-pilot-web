module Chats
  class PublishMessage < ApplicationWorker
    # -- lifetime --
    def initialize(
      encode: EncodeMessage.get,
      chat_message_repo: Chat::Message::Repo.get
    )
      @encode = encode
      @chat_message_repo = chat_message_repo
    end

    ## -- command --
    def call(chat_message_id)
      Files::Host.set_current!
      chat_message = @chat_message_repo.find_with_attachments(chat_message_id)
      Chats::MessageChannel.broadcast_to(chat_message.chat_id, @encode.(chat_message))
    end

    alias :perform :call
  end
end
