module Chats
  class AttachFiles
    def initialize(
      chat_repo: Chat::Repo.get,
      case_repo: Case::Repo.get
    )
      @chat_repo = chat_repo
      @case_repo = case_repo
    end

    def call(session_token, chat_files)
      chat = @chat_repo.find_by_session_with_current_case(session_token)
      kase = @case_repo.find(chat.current_case_id)
      kase.attach_chat_files(chat_files)
      @case_repo.save_new_attachments(kase)
    end
  end
end
