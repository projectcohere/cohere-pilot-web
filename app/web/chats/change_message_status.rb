module Chats
  class ChangeMessageStatus < ::Command
    include ::Logging

    # -- lifetime --
    def initialize(chat_repo: Chat::Repo.get)
      @chat_repo = chat_repo
    end

    # -- command --
    def call(sms)
      status = Chat::Message::Status.from_key(sms.status)
      if status == nil
        return log.debug { "#{self.class.name}:#{__LINE__} -- ignoring message status: #{sms}"}
      end

      chat = @chat_repo.find_by_message_remote_id(sms.id)
      chat.change_message_status(status)
      @chat_repo.save_message_sms(chat)
    end
  end
end
