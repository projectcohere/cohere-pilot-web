class Chat
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repo.new
    end

    def initialize(
      chat_message_repo: Chat::Message::Repo.get,
      domain_events: Services.domain_events
    )
      @chat_message_repo = chat_message_repo
      @domain_events = domain_events
    end

    # -- queries --
    # -- queries/any
    def any_by_phone_number?(phone_number)
      chat_exists = Chat::Record
        .by_phone_number(phone_number)
        .exists?

      return chat_exists
    end

    def any_by_recipient?(recipient_id)
      chat_exists = Chat::Record
        .by_recipient(recipient_id)
        .exists?

      return chat_exists
    end

    # -- queries/one
    def find(id)
      chat_rec = Chat::Record
        .find(id)

      return entity_from(chat_rec)
    end

    def find_chat_recipient(recipient_id)
      chat_recipient_rec = ::Recipient::Record
        .find(recipient_id)

      return self.class.map_recipient(chat_recipient_rec)
    end

    def find_by_phone_number(phone_number)
      chat_rec = Chat::Record
        .by_phone_number(phone_number)
        .first

      return entity_from(chat_rec)
    end

    def find_by_recipient_with_messages(recipient_id)
      chat_rec = Chat::Record
        .by_recipient(recipient_id)
        .first!

      chat_messages = @chat_message_repo
        .find_many_by_chat_with_attachments(chat_rec.id)

      return entity_from(chat_rec, chat_messages)
    end

    def find_by_selected_message(chat_message_id)
      chat_message = @chat_message_repo
        .find_with_attachments(chat_message_id)

      chat_rec = Chat::Record
        .find(chat_message.chat_id)

      chat = entity_from(chat_rec, [chat_message])
        .tap { |chat| chat.select_message(0) }

      return chat
    end

    def find_by_selected_attachment(attachment_id)
      chat_message = @chat_message_repo
        .find_by_selected_attachment(attachment_id)

      chat_rec = Chat::Record
        .find(chat_message.chat_id)

      chat = entity_from(chat_rec, [chat_message])
        .tap { |chat| chat.select_message(0) }

      return chat
    end

    # -- commands --
    def save_opened(chat)
      chat_message = chat.new_message

      # start the new records
      chat_rec = Chat::Record.new({
        recipient_id: chat.recipient.id,
      })

      chat_message_rec = Chat::Message::Record.new({
        chat_id: nil,
      })

      assign_message(chat_message, chat_message_rec)

      # save the records
      transaction do
        chat_rec.save!
        chat_message_rec.chat_id = chat_rec.id
        chat_message_rec.save!
      end

      # send callbacks to entities
      chat_message.did_save(chat_message_rec)
      chat.did_save_new_message
      chat.did_save(chat_rec)

      # consume all entity events
      @domain_events.consume(chat.events)
    end

    def save_new_message(chat)
      assert(chat.record != nil, "chat must be persisted")

      message = chat.new_message
      assert(message != nil, "chat must have a new message")

      # build the records
      message_rec = chat.record.messages.build
      assign_message(message, message_rec)

      # save the records
      transaction do
        message_rec.save!
        create_attachments!(message, message_rec)
      end

      # send callbacks to entities
      message.did_save(message_rec)

      # consume all entity events
      @domain_events.consume(chat.events)
    end

    def save_uploaded_attachment(chat)
      attachment = chat.selected_attachment
      assert(attachment.record != nil, "selected attachment must be persisted")

      # update the records
      attachment_rec = attachment.record

      a = attachment
      attachment_rec.assign_attributes(
        remote_url: a.remote_url,
      )

      # save the records
      transaction do
        attachment_rec.file = create_file!(a.file)
        attachment_rec.save!
      end

      # consume all entity events
      @domain_events.consume(chat.events)
    end

    def save_prepared_message(chat)
      # consume all entity events
      @domain_events.consume(chat.events)
    end

    # -- commands/helpers --
    private def assign_message(message, message_rec)
      m = message
      message_rec.assign_attributes({
        sender: m.sender,
        body: m.body,
      })
    end

    private def create_attachments!(message, message_rec)
      attachments = message.attachments
      if attachments.blank?
        return
      end

      attachments.each do |a|
        if a.remote?
          message_rec.attachments.build({
            remote_url: a.remote_url,
          })
        end
      end

      message_rec.save!
    end

    private def create_file!(f)
      return ActiveStorage::Blob.create_after_upload!(
        io: f.data,
        filename: f.name,
        content_type: f.mime_type,
        identify: false,
      )
    end

    private def transaction
      Chat::Record.transaction do
        yield
      end
    end

    # -- factories --
    def self.map_record(r, messages = [])
      recipient = map_recipient(r.recipient)

      return Chat.new(
        record: r,
        id: Id.new(r.id),
        recipient: recipient,
        messages: messages,
      )
    end

    def self.map_recipient(r)
      return Recipient.new(
        id: r.id,
        profile: ::Recipient::Repo.map_profile(r),
      )
    end
  end

  class Record
    # -- scopes --
    def self.by_recipient(recipient_id)
      return where(recipient_id: recipient_id)
    end

    def self.by_phone_number(phone_number)
      scope = self
        .left_joins(:recipient)
        .where(recipients: { phone_number: phone_number })

      return scope
    end
  end
end
