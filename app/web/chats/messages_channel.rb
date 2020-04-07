module Chats
  class MessagesChannel < ApplicationCable::Channel
    # -- ActionCable::Channel::Base
    def subscribed
      chat = find_current_chat!(params[:chat])
      stream_for(chat.id)
    end

    def receive(event)
      assert(sender != nil, "must be a cohere user to send messages")

      if event["name"] != "ADD_MESSAGE"
        return
      end

      data = event["data"]
      AddWebMessage.(
        find_current_chat!(data["chat"]),
        sender,
        Incoming.new(**data["message"]&.symbolize_keys),
      )

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
