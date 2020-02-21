class Chat
  class Message < ::Entity
    prop(:id, default: Id::None)
    prop(:sender)
    prop(:body)
    prop(:timestamp)
    prop(:attachments, default: [])
    prop(:chat_id)

    # -- queries --
    def sent_by?(other)
      case @sender
      when Chat::Sender::Recipient
        other == Chat::Sender::Recipient
      else
        other != Chat::Sender::Recipient
      end
    end

    def sent_by_recipient?
      sent_by?(Chat::Sender::Recipient)
    end

    # -- callbacks --
    def did_save(record)
      @id.set(record.id)
    end
  end
end
