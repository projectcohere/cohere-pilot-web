module Chats
  class Connection < ActionCable::Connection::Base
    identified_by(:current_chat)

    # -- commands --
    def connect
      recipient_token = cookies.encrypted.signed[:recipient_token]
      if not recipient_token.nil?
        @current_chat = Chat::Repo.get.find_by_recipient_token(recipient_token)
      end
    end
  end
end
