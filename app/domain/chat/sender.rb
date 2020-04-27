class Chat
  module Sender
    # -- constants --
    Recipient = "recipient".freeze
    Automated = "automated".freeze

    # -- options --
    def self.agent(chat_token)
      return chat_token
    end

    def self.recipient
      return Recipient
    end

    def self.automated
      return Automated
    end

    # -- queries --
    def self.recipient?(sender)
      return sender == Recipient
    end
  end
end
