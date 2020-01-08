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
      chat_sender = if connection.chat_user_id != nil
        Chat::Sender.cohere(connection.chat_user_id)
      else
        Chat::Sender.recipient
      end

      # receive message
      message_data = data["message"]
      chat.add_message(
        sender: chat_sender,
        type: message_data["type"].to_sym,
        body: message_data["body"]
      )

      # save entity
      Chat::Repo.get.save_new_messages(chat)

      process_events
    end

    # -- callbacks --
    def process_events
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
