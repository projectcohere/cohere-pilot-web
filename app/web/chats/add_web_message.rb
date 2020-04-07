module Chats
  class AddWebMessage < ::Command
    # -- lifetime --
    def initialize(
      chat_repo: Chat::Repo.get,
      file_repo: File::Repo.get
    )
      @chat_repo = chat_repo
      @file_repo = file_repo
    end

    # -- command --
    def call(chat, sender, incoming)
      # find all attachments, if necessary
      attachments = if incoming.attachment_ids.present?
        @file_repo.find_all_by_ids(incoming.attachment_ids)
      end

      # add the message to the chat
      chat.add_message(
        sender: sender,
        body: incoming.body,
        files: attachments || [],
        status: Chat::Message::Status::Queued,
        client_id: incoming.id,
      )

      # save aggregate
      @chat_repo.save_new_message(chat)
    end
  end
end
