module Chats
  class Channel < ActionCable::Channel::Base
    # -- ActionCable::Channel::Base
    def subscribed
      if not current_chat.nil?
        stream_for(current_chat)

        broadcast_to(current_chat, {
          sender: Chat::Sender::Cohere,
          message: {
            type: Chat::Type::Text,
            body: "Hi there, let's get started on your application."
          }
        })
      end
    end

    def receive(data)
      current_chat.add_message(
        sender: Chat::Sender::Recipient,
        type: data["type"].to_sym,
        body: data["body"]
      )

      Chat::Repo.get.save_new_messages(current_chat)

      process_events
    end

    # -- callbacks --
    def process_events
      Events::ProcessAll.get.()
    end

    # -- queries --
    private def current_chat
      connection.current_chat
    end
  end
end
