module Chats
  class Channel < ActionCable::Channel::Base
    # -- ActionCable::Channel::Base
    def subscribed
      chat = find_current_chat(params[:chat])
      stream_for(chat)
    end

    def receive(data)
      chat = find_current_chat(data["chat"])

      # determine sender based on auth method
      chat_sender = if connection.current_user != nil
        Chat::Sender::Cohere
      else
        Chat::Sender::Recipient
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
      if connection.current_chat != nil
        return connection.current_chat
      elsif chat_id != nil
        return Chat::Repo.get.find(chat_id)
      end
    end
  end
end
