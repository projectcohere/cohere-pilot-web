module Chats
  class AddSmsMessage < ::Command
    include ::Logging

    # -- lifetime --
    def initialize(
      chat_repo: Chat::Repo.get,
      file_repo: File::Repo.get
    )
      @chat_repo = chat_repo
      @file_repo = file_repo
    end

    # -- command --
    def call(sms)
      chat = @chat_repo.find_by_phone_number(sms.phone_number)
      if chat == nil
        return log.info { "#{self.class.name}:#{__LINE__} -- received SMS from unknown phone number: #{sms.phone_number}"}
      end

      # add the message to the chat
      chat.add_message(
        sender: Chat::Sender::Recipient,
        body: sms.body,
        files: sms.media || [],
        status: Chat::Message::Status::Received,
        remote_id: sms.id,
      )

      # save aggregate
      @chat_repo.save_new_message(chat)
    end
  end
end
