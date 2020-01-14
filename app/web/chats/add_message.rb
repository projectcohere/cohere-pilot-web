module Chats
  class AddMessage < ::Command
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
      attachments = nil
      attachment_ids = incoming.attachment_ids
      if attachment_ids.present?
        attachments = @file_repo.find_all_by_ids(attachment_ids)
      end

      # add the message to the chat
      chat.add_message(
        sender: sender,
        body: incoming.body,
        attachments: attachments || [],
      )

      # save aggregate
      @chat_repo.save_new_message(chat)
    end
  end
end
