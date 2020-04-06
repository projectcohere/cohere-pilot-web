module Chats
  class MessagesChannel < ApplicationCable::Channel
    # -- ActionCable::Channel::Base
    def subscribed
      chat = find_current_chat!(params[:chat])
      stream_for(chat.id)
    end

    def receive(data)
      assert(sender != nil, "must be a cohere user to send messages")

      # add incoming message to chat
      chat = find_current_chat!(data["chat"])
      AddWebMessage.(chat, sender, Incoming.new(
        body: data["message"]["body"],
        attachment_ids: data["message"]["attachment_ids"],
      ))

      # dispatch events
      Events::DispatchAll.()
    end

    # -- queries --
    private def sender
      return Chat::Sender.cohere(connection.chat_user_id)
    end

    private def find_current_chat!(chat_id)
      chat = Chat::Repo.get.find(chat_id)
      assert(chat != nil, "could not find chat with id #{chat_id}")
      return chat
   end
  end
end
