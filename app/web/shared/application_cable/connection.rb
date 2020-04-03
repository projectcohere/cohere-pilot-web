module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by(
      :user,
    )

    # -- props --
    attr(:chat_user_id)

    # -- commands --
    def connect
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
  end
end
