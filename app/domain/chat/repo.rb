class Chat
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repo.new
    end

    def initialize(domain_events: Services.domain_events)
      @domain_events = domain_events
    end

    # -- queries --
    # -- queries/one
    def find(id)
      chat_rec = Chat::Record
        .find(id)

      return entity_from(chat_rec)
    end

    def find_by_invitation(invitation_token)
      chat_rec = Chat::Record
        .where("invitation_token_expires_at >= ?", Time.zone.now)
        .find_by(invitation_token: invitation_token)

      return entity_from(chat_rec)
    end

    def find_by_session(session_token)
      chat_rec = Chat::Record
        .with_a_session
        .find_by!(session_token: session_token)

      return entity_from(chat_rec)
    end

    def find_by_session_with_messages(session_token)
      chat_rec = Chat::Record
        .with_a_session
        .find_by(session_token: session_token)

      chat_message_recs = if chat_rec != nil
        Chat::Message::Record
          .where(chat_id: chat_rec.id)
      end

      return entity_from(chat_rec, chat_message_recs)
    end

    def find_by_session_with_current_case(session_token)
      chat_rec = Chat::Record
        .with_a_session
        .find_by!(session_token: session_token)

      case_rec = chat_rec.recipient.cases
        .where.not(status: [:submitted, :approved, :denied])
        .first!

      return entity_from(chat_rec, [], case_rec)
    end

    def find_by_recipient_with_messages(recipient_id)
      chat_rec = Chat::Record
        .find_by!(recipient_id: recipient_id)

      chat_message_recs = Chat::Message::Record
        .where(chat_id: chat_rec.id)

      return entity_from(chat_rec, chat_message_recs)
    end

    # -- commands --
    def save_new_session(chat)
      chat_rec = chat.record
      if chat_rec.nil?
        raise "chat must be fetched from the db!"
      end

      chat_rec.assign_attributes(
        invitation_token: nil,
        invitation_token_expires_at: nil,
        session_token: chat.session,
      )

      chat_rec.save!
    end

    def save_new_messages(chat)
      chat_rec = chat.record
      if chat_rec.nil?
        raise "chat must be fetched from the db!"
      end

      messages = chat.new_messages

      # build list of attributes
      message_attrs = chat.new_messages.map do |m|
        _attrs = {
          sender: m.sender,
          mtype: m.type,
          body: m.body,
          chat_id: m.chat_id,
        }
      end

      # create the records
      message_recs = Chat::Message::Record.create!(message_attrs)

      # send callbacks to entities
      message_recs.each_with_index do |r, i|
        messages[i].did_save(r)
      end

      chat.did_save_new_messages

      # consume all entity events
      @domain_events.consume(chat.events)
    end

    # -- factories --
    def self.map_record(r, message_recs = [], current_case_rec = nil)
      Chat.new(
        record: r,
        id: Id.new(r.id),
        session: r.session_token,
        invitation: r.invitation_token&.then { |t|
          Chat::Invitation.new(
            token: r.invitation_token,
            expires_at: r.invitation_token_expires_at,
          )
        },
        messages: message_recs.map { |m|
          Chat::Message::Repo.map_record(m)
        },
        current_case_id: current_case_rec&.id,
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
