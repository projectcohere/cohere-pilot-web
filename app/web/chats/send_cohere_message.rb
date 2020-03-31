module Chats
  class SendCohereMessage < ApplicationWorker
    # -- lifetime --
    def initialize(
      send_sms: Twilio::SendSms.get,
      chat_repo: Chat::Repo.get
    )
      @send_sms = send_sms
      @chat_repo = chat_repo
    end

    ## -- command --
    def call(chat_message_id)
      Files::Host.set_current!

      chat = @chat_repo.find_by_selected_message(chat_message_id)

      m = chat.selected_message
      p = chat.recipient.profile.phone

      @send_sms.(p.number,
        body: m.body,
        media_urls: m.attachments.map { |a| a.service_url },
      )
    end

    alias :perform :call
  end
end
