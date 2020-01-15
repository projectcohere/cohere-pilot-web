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
    # -- queries/one
    def find(id)
      chat_rec = Chat::Record
        .find(id)

      return entity_from(chat_rec)
    end

    def find_by_phone_number(phone_number)
      chat_rec = Chat::Record
        .includes(:recipient).references(:recipients)
        .find_by(recipients: { phone_number: phone_number })

      return entity_from(chat_rec)
    end

    def find_by_session(session_token)
      chat_rec = Chat::Record
        .with_a_session
        .find_by(session_token: session_token)

      return entity_from(chat_rec)
    end

    def find_by_session_with_messages(session_token)
      chat_rec = Chat::Record
        .with_a_session
        .find_by(session_token: session_token)

      chat_messages = if chat_rec != nil
        @chat_message_repo
          .find_many_by_chat_with_attachments(chat_rec.id)
      end

      return entity_from(chat_rec, chat_messages)
    end

    def find_by_recipient_with_messages(recipient_id)
      chat_rec = Chat::Record
        .find_by!(recipient_id: recipient_id)

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

    # -- commands --
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

      message = chat.new_message
      if message == nil
        raise "chat must have a new message!"
      end

      # create the record
      m = message
      message_rec = Chat::Message::Record.create!({
        sender: m.sender,
        body: m.body,
        chat_id: m.chat_id,
        files: m.attachments,
      })

      # send callbacks to entities
      message.did_save(message_rec)
      chat.did_save_new_message

      # consume all entity events
      @domain_events.consume(chat.events)
    end

    # -- factories --
    def self.map_record(r, messages = [])
      Chat.new(
        record: r,
        id: Id.new(r.id),
        session: r.session_token,
        messages: messages,
        recipient_id: r.recipient_id,
      )
    end
  end

  class Record
    # -- scopes --
    def self.with_a_session
      where.not(session_token: nil)
    end
  end
end
