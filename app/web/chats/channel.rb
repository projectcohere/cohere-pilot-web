module Chats
  class Channel < ActionCable::Channel::Base
    # -- ActionCable::Channel::Base
    def subscribed
      if not current_chat.nil?
        stream_for(current_chat)

        broadcast_to(current_chat, {
          sender: "Gaby",
          message: {
            type: :text,
            body: "Hello! Welcome to the chat."
          }
        })
      end
    end

    def receive(data)
    end

    # -- queries --
    private def current_chat
      connection.current_chat
    end
  end
end
