class ChatsController < ApplicationController
  def connect
    chat_token_value = params[:recipient_token]
    chat = if not chat_token_value.nil?
      Chat::Repo.get.find_by_recipient_token(chat_token_value)
    end

    if chat.nil?
      redirect_to(join_chat_path)
      return
    end

    cookies.encrypted.signed[:recipient_token] = chat.recipient_token.value
    redirect_to(chat_path)
  end

  def show
    chat_token = cookies.encrypted.signed[:recipient_token]
    chat = if not chat_token.nil?
      Chat::Repo.get.find_by_recipient_token(chat_token)
    end

    if chat.nil?
      redirect_to(join_chat_path)
      return
    end
  end
end
