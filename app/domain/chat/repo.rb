class Chat
  class Repo < ::Repo
    include Service

    # -- lifetime --
    def initialize(
      domain_events: Service::Container.domain_events,
      message_repo: Chat::Message::Repo.get
    )
      @domain_events = domain_events
      @message_repo = message_repo
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

      messages = @message_repo
        .find_all_by_chat_with_attachments(chat_rec.id)

      return entity_from(chat_rec, messages)
    end

    def find_by_message_with_attachments(message_id)
      message = @message_repo
        .find_with_attachments(message_id)

      return find_with_message(message)
    end

    def find_by_message_remote_id(message_remote_id)
      message = @message_repo
        .find_by_remote_id(message_remote_id)

      return find_with_message(message)
    end

    def find_by_attachment(attachment_id)
      message = @message_repo
        .find_by_attachment(attachment_id)

      return find_with_message(message)
    end

    # -- queries/helpers
    private def find_with_message(message)
      chat_rec = Chat::Record.find(message.chat_id)
      chat = entity_from(chat_rec, [message])
      chat.select_message(0)
      return chat
    end

    # -- commands --
    def save_opened(chat)
      message = chat.new_message

      # start the new records
      chat_rec = Chat::Record.new({
        recipient_id: chat.recipient.id,
      })

      message_rec = Message::Record.new({
        chat_id: nil,
      })

      assign_message(message, message_rec)

      # save the records
      transaction do
        chat_rec.save!
        message_rec.chat_id = chat_rec.id
        message_rec.save!
        create_attachments!(message, message_rec)
      end

      # send callbacks to entities
      message.did_save(message_rec)
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

    def save_message_sms(chat)
      message = chat&.selected_message
      assert(message.record != nil, "chat and message must be persisted")

      # update the record
      message_rec = message.record
      assign_message_sms(message, message_rec)

      # save the record
      message_rec.save!

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

      assign_message_sms(message, message_rec)
    end

    private def assign_message_sms(message, message_rec)
      m = message
      message_rec.assign_attributes({
        status: m.status.key,
        remote_id: m.remote_id,
      })
    end

    private def create_attachments!(message, message_rec)
      attachments = message.attachments
      if attachments.blank?
        return
      end

      attachments.each do |a|
        attachment_rec = message_rec.attachments.build

        if a.remote?
          attachment_rec.remote_url = a.remote_url
        elsif # a.is_a?(ActiveStorage::Blob)
          attachment_rec.file = a.file
        end
      end

      message_rec.save!
    end

    private def create_file!(file)
      f = file

      # TODO: change to create_and_upload! after upgrade to Rails 6.0.2
      return ActiveStorage::Blob.create_after_upload!(
        io: f.data,
        filename: f.name,
        content_type: f.mime_type,
        identify: false,
      )
    end

    private def transaction(&block)
      Chat::Record.transaction(&block)
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
        .includes(:recipient)
        .references(:recipients)
        .where(recipients: { phone_number: phone_number })

      return scope
    end
  end
end
