module Chats
  class SendNotification < ApplicationWorker
    sidekiq_options(
      lock: :until_executed
    )

    # -- lifetime --
    def initialize(
      chat_repo: Chat::Repo.get,
      send_sms: Front::SendSms.get,
      send_initial_sms: Front::SendInitialSms.get
    )
      @chat_repo = chat_repo
      @send_sms = send_sms
      @send_initial_sms = send_initial_sms
    end

    ## -- command --
    def call(chat_id)
      chat = @chat_repo.find(chat_id)

      # short-circuit if the recipient read the chat in the meantime
      if chat.notification == nil
        return
      end

      # send the sms, creating a conversation if necessary
      chat.send_sms_notification do
        if chat.sms_conversation_id != nil
          @send_sms.(chat.sms_conversation_id, "Test reply notification.")
        else
          @send_initial_sms.(chat.recipient.profile.phone.number, "Test new conversation notification.")
        end
      end

      # save the records
      @chat_repo.save_notification(chat)
    end

    alias :perform :call
  end
end
