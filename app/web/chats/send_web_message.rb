module Chats
  class SendWebMessage < ApplicationWorker
    # -- lifetime --
    def initialize(
      encode: EncodeMessage.get,
      message_repo: Chat::Message::Repo.get
    )
      @encode = encode
      @message_repo = message_repo
    end

    ## -- command --
    def call(message_id)
      message = @message_repo.find_with_attachments(message_id)
      Files::Host.set_current!
      Chats::MessageChannel.broadcast_to(message.chat_id, @encode.(message))
    end
  end
end
