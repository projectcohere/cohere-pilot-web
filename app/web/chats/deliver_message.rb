module Chats
  class DeliverMessage < ApplicationWorker
    # -- lifetime --
    def initialize(chat_message_repo: Chat::Message::Repo.get)
      @chat_message_repo = chat_message_repo
    end

    ## -- command --
    def call(chat_message_id)
      Files::Host.set_current!
      chat_message = @chat_message_repo.find_with_attachments(chat_message_id)
      Chats::Channel.broadcast_to(chat_message.chat_id, serialize_message(chat_message))
    end

    alias :perform :call

    # -- serialization --
    def serialize_message(m)
      serialized = {
        sender: m.sender,
        message: {
          body: m.body,
          attachments: m.attachments.map { |a| serialize_attachment(a) },
        },
      }

      return serialized
    end

    def serialize_attachment(a)
      serailized = {
        previewUrl: a.representable? ? a.representation(resize: "200x200>").processed.service_url : nil
      }

      return serailized
    end
  end
end
