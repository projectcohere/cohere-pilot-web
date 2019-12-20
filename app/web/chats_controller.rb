class ChatsController < ApplicationController
  def connect
    cookies.encrypted.signed[:recipient_token] = params[:recipient_token]
    redirect_to(chat_path)
  end

  def show
    chat_token = cookies.encrypted.signed[:recipient_token]
    @chat = if not chat_token.nil?
      Chat::Repo.get.find_by_recipient_token(chat_token)
    end

    if @chat.nil?
      cookies.delete(:recipient_token)
      redirect_to(join_chat_path)
      return
    end
  end
end
