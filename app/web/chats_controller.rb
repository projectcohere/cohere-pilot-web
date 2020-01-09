class ChatsController < ApplicationController
  def start
    start_session = Chats::StartSession.new
    session_token = start_session.(params[:invitation_token])

    if session_token == nil
      return redirect_to(join_chat_path)
    end

    cookies.encrypted.signed[:chat_session_token] = session_token
    redirect_to(chat_path)
  end

  def show
    session_token = cookies.encrypted.signed[:chat_session_token]
    if session_token == nil
      return redirect_to(join_chat_path)
    end

    @chat = Chat::Repo.get.find_by_session_with_messages(session_token)

    # if the chat expired, redirect to join page
    if @chat.nil?
      cookies.delete(:chat_session_token)
      return redirect_to(join_chat_path)
    end
  end

  def files
    session_token = cookies.encrypted.signed[:chat_session_token]
    if session_token == nil
      raise(ActionController::RoutingError, "No chat session connected.")
    end

    attach_files = Chats::AttachFiles.new
    attach_files.(session_token, params[:files].values)
  end
end
