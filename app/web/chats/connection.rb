module Chats
  class Connection < ActionCable::Connection::Base
    identified_by(
      :current_user,
      :current_chat
    )

    # -- commands --
    def connect
      connect_by_user || connect_by_chat
    end

    private def connect_by_user
      remember_token = cookies[:remember_token]
      if remember_token.nil?
        return false
      end

      @current_user = User::Repo.get.find_by_remember_token(remember_token)
      return true
    end

    private def connect_by_chat
      recipient_token = cookies.encrypted.signed[:recipient_token]
      if recipient_token.nil?
        return false
      end

      @current_chat = Chat::Repo.get.find_by_recipient_token(recipient_token)
      return true
    end
  end
end
