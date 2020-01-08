class Chat
  class Message < ::Entity
    prop(:id, default: Id::None)
    prop(:type)
    prop(:body)
    prop(:sender)
    prop(:chat_id)
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

    # -- callbacks --
    def did_save(record)
      @id.set(record.id)
    end
  end
end
