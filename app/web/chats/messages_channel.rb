module Chats
  class MessagesChannel < ApplicationCable::Channel
    # -- ActionCable::Channel::Base
    def subscribed
      chat = find_current_chat!(params[:chat])
      stream_for(chat.id)
    end

    def receive(event)
      assert(sender != nil, "must be a cohere user to send messages")

      if event["name"] == "ADD_MESSAGE"
        add_web_message(event["data"])
      end

      # dispatch events
      Events::DispatchAll.()
    end

    # -- commands --
    private def add_web_message(data)
      chat = find_current_chat!(data["chat"])

      # add inbound message
      inbound = InboundMessage.new(**data["message"]&.symbolize_keys)
      AddWebMessage.(chat, sender, inbound)

      # send save event back to client
      message = chat.new_message
      if message.id.val != nil
        transmit(MessagesEvent.did_save_message(inbound, message))
      end
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
