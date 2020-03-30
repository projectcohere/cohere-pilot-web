module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by(
      :user,
      :chat
    )

    # -- props --
    attr(:chat_user_id)

    # -- commands --
    def connect
      connect_by_user || connect_by_chat_session
    end

    private def connect_by_user
      remember_token = cookies[:remember_token]
      if remember_token.nil?
        return false
      end

      @user = User::Repo.get.find_by_remember_token(remember_token)
      if @user == nil
        reject_unauthorized_connection
      end

      @chat_user_id = cookies.signed[:chat_user_id]

      return true
    end

    private def connect_by_chat_session
      session_token = cookies.encrypted.signed[:chat_session_token]
      if session_token.blank?
        return false
      end

      @chat = Chat::Repo.get.find_by_session(session_token)
      if @chat == nil
        raise "Could not find chat"
        reject_unauthorized_connection
      end

      return true
    end
  end
end
