module Chats
  class AddSmsMessage < ::Command
    # -- lifetime --
    def initialize(
      chat_repo: Chat::Repo.get,
      file_repo: File::Repo.get
    )
      @chat_repo = chat_repo
      @file_repo = file_repo
    end

    # -- command --
    def call(inbound)
      chat = @chat_repo.find_by_phone_number(inbound.phone_number)
      if chat.nil?
        raise "No case found for phone number #{inbound.phone_number}"
      end

      # add the message to the chat
      chat.add_message(
        sender: Chat::Sender::Recipient,
        body: inbound.body,
        files: inbound.media || [],
        status: Chat::Message::Status::Received,
        remote_id: inbound.id,
      )

      # save aggregate
      @chat_repo.save_new_message(chat)
    end
  end
end
