class Chat
  class Message < ::Entity
    prop(:id, default: 0)
    prop(:type)
    prop(:body)
    prop(:sender)
    props_end!

    # -- queries --
    def sent_by?(other)
      case @sender
      when Chat::Sender::Recipient
        other == Chat::Sender::Recipient
      else
        other != Chat::Sender::Recipient
      end
    end
  end
end
