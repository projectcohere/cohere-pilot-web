class Chat
  class Message < ::Entity
    # -- props --
    prop(:id, default: Id::None)
    prop(:sender)
    prop(:body)
    prop(:status)
    prop(:timestamp)
    prop(:attachments, default: []) # IO | Sms::Media | ActiveStorage::Blob
    prop(:chat_id)
    prop(:remote_id, default: nil)

    # -- props/temporary
    attr(:selected_attachment)

    # -- commands --
    def select_attachment(attachment_id)
      @selected_attachment = @attachments.find do |m|
        m.id.val == attachment_id
      end
    end

    # -- queries --
    def prepared?
      return @attachments.none?(&:remote?)
    end

    def sent_by?(other)
      case @sender
      when Chat::Sender::Recipient
        return other == Chat::Sender::Recipient
      else
        return other != Chat::Sender::Recipient
      end
    end

    def sent_by_recipient?
      return sent_by?(Chat::Sender::Recipient)
    end

    # -- callbacks --
    def did_save(record)
      @id.set(record.id)
      @attachments.each_with_index do |a, i|
        a.did_save(record.attachments[i])
      end
    end
  end
end
