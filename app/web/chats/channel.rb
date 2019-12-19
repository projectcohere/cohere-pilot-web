module Chats
  class Channel < ActionCable::Channel::Base
    def subscribed
      if not current_chat.nil?
        stream_for(current_chat)

        broadcast_to(current_chat, {
          user: "Gaby",
          type: :text,
          body: "Hello! Welcome to the chat."
        })
      end
    end

    # -- queries --
    private def current_chat
      connection.current_chat
    end
  end
end
