class ChatsController < ApplicationController
  def connect
    chat_token = params[:remember_token]
    chat = if not chat_token.nil?
      Chat::Repo.get.find_by_remember_token(chat_token)
    end

    if chat.nil?
      redirect_to(join_chat_path)
      return
    end

    session[:remember_token] = chat.remember_token.value
    redirect_to(chat_path)
  end

  def show
    chat_token = session[:remember_token]
    chat = if not chat_token.nil?
      Chat::Repo.get.find_by_remember_token(chat_token)
    end

    if chat.nil?
      redirect_to(join_chat_path)
      return
    end
  end
end
