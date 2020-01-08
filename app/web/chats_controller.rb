class ChatsController < ApplicationController
  def connect
    cookies.encrypted.signed[:chat_recipient_token] = params[:token]
    redirect_to(chat_path)
  end

  def show
    chat_token = cookies.encrypted.signed[:chat_recipient_token]
    @chat = if chat_token != nil
      Chat::Repo.get.find_by_recipient_token_with_messages(chat_token)
    end

    # if the chat expired, redirect to join page
    if @chat.nil?
      cookies.delete(:chat_recipient_token)
      redirect_to(join_chat_path)
      return
    end
  end

  def files
    chat_token = cookies.encrypted.signed[:chat_recipient_token]
    if chat_token == nil
      raise(ActionController::RoutingError, "No chat session connected.")
    end

    attach_files = Chats::AttachFiles.new
    attach_files.(chat_token, params[:files].values)
  end
end
