class Chat
  module Sender
    # -- constants --
    Recipient = "recipient".freeze
    Automated = "automated".freeze

    # -- options --
    def self.cohere(chat_token)
      chat_token
    end

    def self.recipient
      Recipient
    end

    def self.automated
      Automated
    end
  end
end
