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

    def find_by_session(session_token)
      chat_rec = Chat::Record
        .with_any_session
        .find_by(session_token: session_token)

      return entity_from(chat_rec)
    end

    def find_by_session_with_messages(session_token)
      chat_rec = Chat::Record
        .with_any_session
        .find_by(session_token: session_token)

      chat_messages = if chat_rec != nil
        @chat_message_repo
          .find_many_by_chat_with_attachments(chat_rec.id)
      end

      return entity_from(chat_rec, chat_messages)
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

    # -- queries/many
    def find_all_ids_for_reminder1
      chat_recs = Chat::Record
        .reminder_1
        .where("updated_at <= ?", 15.minutes.ago)
        .select(:id)

      return chat_recs.pluck(:id)
    end

    # -- commands --
    def save_opened(chat)
      chat_message = chat.new_message

      # start the new records
      chat_rec = Chat::Record.new({
        recipient_id: chat.recipient.id,
      })

      assign_notification(chat, chat_rec)

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

    def save_new_session(chat)
      chat_rec = chat.record
      if chat_rec.nil?
        raise "chat must be fetched from the db!"
      end

      chat_rec.assign_attributes(
        session_token: chat.session,
      )

      chat_rec.save!
    end

    def save_new_message(chat)
      chat_rec = chat.record
      if chat_rec == nil
        raise "chat must be fetched from the db!"
      end

      chat_message = chat.new_message
      if chat_message == nil
        raise "chat must have a new chat_message!"
      end

      # build/update the records
      chat_message_rec = Chat::Message::Record.new({
        chat_id: chat_message.chat_id,
      })

      assign_notification(chat, chat_rec)
      assign_message(chat_message, chat_message_rec)

      # save the records
      transaction do
        chat_rec.save!
        chat_message_rec.save!
      end

      # send callbacks to entities
      chat_message.did_save(chat_message_rec)
      chat.did_save_new_message

      # consume all entity events
      @domain_events.consume(chat.events)
    end

    def save_notification(chat)
      chat_rec = chat.record
      if chat_rec == nil
        raise "chat must be fetched from the db!"
      end

      # update the records
      chat_rec.assign_attributes({
        sms_conversation_id: chat.sms_conversation_id
      })

      assign_notification(chat, chat_rec)

      # save the records
      chat_rec.save!

      # consume all entity events
      @domain_events.consume(chat.events)
    end

    # -- commands/helpers --
    def assign_notification(chat, chat_rec)
      c = chat
      chat_rec.assign_attributes({
        notification: c.notification != nil ? "reminder_1" : "clear",
      })
    end

    def assign_message(chat_message, chat_message_rec)
      m = chat_message
      chat_message_rec.assign_attributes({
        sender: m.sender,
        body: m.body,
        files: m.attachments,
      })
    end

    def transaction
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
        session: r.session_token,
        messages: messages,
        notification: map_notification(r, recipient),
        sms_conversation_id: r.sms_conversation_id,
      )
    end

    def self.map_recipient(r)
      return Recipient.new(
        id: r.id,
        profile: ::Recipient::Repo.map_profile(r),
      )
    end

    def self.map_notification(r, recipient)
      if r.notification == "clear"
        return nil
      end

      return Notification.new(
        recipient_name: recipient.profile.name,
        is_new_conversation: r.sms_conversation_id == nil,
      )
    end
  end

  class Record
    # -- scopes --
    def self.with_any_session
      return where.not(session_token: nil)
    end

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
