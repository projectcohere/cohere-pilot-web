module Chats
  class MessageChannel < ApplicationCable::Channel
    # -- ActionCable::Channel::Base
    def subscribed
      chat = find_current_chat(params[:chat])
      stream_for(chat.id)
    end

    def receive(data)
      chat = find_current_chat(data["chat"])

      # TODO: only cohere users should be sending messages now
      if connection.chat_user_id == nil
        raise ""
      end

      # add incoming message to chat
      sender = Chat::Sender.cohere(connection.chat_user_id)
      AddCohereMessage.(chat, sender, Incoming.new(
        body: data["message"]["body"],
        attachment_ids: data["message"]["attachment_ids"],
      ))

      # handle events
      Events::DispatchAll.get.()
    end

    # -- queries --
    private def find_current_chat(chat_id)
      if chat_id != nil
        return Chat::Repo.get.find(chat_id)
      end
    end
  end
end
