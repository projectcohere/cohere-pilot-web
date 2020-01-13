module Chats
  class Channel < ActionCable::Channel::Base
    # -- ActionCable::Channel::Base
    def subscribed
      chat = find_current_chat(params[:chat])
      stream_for(chat.id)
    end

    def receive(data)
      chat = find_current_chat(data["chat"])

      # determine sender based on auth method
      sender = if connection.chat_user_id != nil
        Chat::Sender.cohere(connection.chat_user_id)
      else
        Chat::Sender.recipient
      end

      # add incoming message to chat
      incoming = Incoming.new(
        body: data["message"]["body"],
        attachment_ids: data["message"]["attachmentIds"],
      )

      add_message = AddMessage.new
      add_message.(chat, sender, incoming)

      # handle events
      Events::ProcessAll.get.()
    end

    # -- queries --
    private def find_current_chat(chat_id)
      if connection.chat != nil
        return connection.chat
      elsif chat_id != nil
        return Chat::Repo.get.find(chat_id)
      end
    end
  end
end
