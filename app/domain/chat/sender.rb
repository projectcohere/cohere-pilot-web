class Chat
  module Sender
    # -- constants --
    Recipient = "recipient".freeze

    # -- options --
    def self.cohere(chat_token)
      chat_token
    end

    def self.recipient
      Recipient.to_s
    end
  end
end
