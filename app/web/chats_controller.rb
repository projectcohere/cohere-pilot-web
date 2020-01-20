class ChatsController < ApplicationController
  def show
    session_token = cookies.encrypted.signed[:chat_session_token]
    if session_token == nil
      return redirect_to(verify_chat_invites_path)
    end

    # find chat, or redirect if it expired
    @chat = Chat::Repo.get.find_by_session_with_messages(session_token)

    if @chat.nil?
      cookies.delete(:chat_session_token)
      return redirect_to(verify_chat_invites_path)
    end
  end

  def files
    session_token = cookies.encrypted.signed[:chat_session_token]
    if session_token == nil
      return head(:not_found)
    end

    chat = Chat::Repo.get.find_by_session(session_token)
    if chat == nil
      cookies.delete(:chat_session_token)
      return head(:not_found)
    end

    file_ids = File::Repo.get
      .save_uploaded_files(params[:files].values)

    render(json: {
      "data" => {
        "fileIds" => file_ids
      }
    })
  end
end
