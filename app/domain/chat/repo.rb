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

      entity_from(chat_rec)
    end

    def find_by_recipient(recipient_id)
      chat_rec = Chat::Record
        .find_by(recipient_id: recipient_id)

      entity_from(chat_rec)
    end

    def find_by_recipient_token(recipient_token)
      chat_rec = Chat::Record
        .where("recipient_token_expires_at >= ?", Time.zone.now)
        .find_by(recipient_token: recipient_token)

      entity_from(chat_rec)
    end

    def find_by_recipient_token_with_current_case(recipient_token)
      chat_rec = Chat::Record
        .where("recipient_token_expires_at >= ?", Time.zone.now)
        .find_by!(recipient_token: recipient_token)

      case_rec = chat_rec.recipient.cases
        .where.not(status: [:submitted, :approved, :denied])
        .first!

      entity_from(chat_rec, case_rec.id)
    end

    def find_with_message(id, message_id)
      chat_rec = Chat::Record
        .select(Chat::Record.column_names - ["messages"])
        .select("jsonb_build_array(messages->#{message_id}) as messages")
        .where("messages->0 IS NOT NULL")
        .find(id)

      entity_from(chat_rec).tap do |chat|
        chat.select_message(0)
      end
    end

    # -- commands --
    def save_new_messages(chat)
      chat_rec = chat.record
      if chat_rec.nil?
        raise "chat must be fetched from the db!"
      end

      # update the record
      chat.new_messages.each do |m|
        chat_rec.messages << {
          id: m.id,
          sender: m.sender,
          type: m.type,
          body: m.body,
        }
      end

      # save the record
      chat_rec.save!

      # send callbacks to entity
      chat.did_save_new_messages

      # consume all entity events
      @domain_events.consume(chat.events)
    end

    # -- factories --
    def self.map_record(r, current_case_id = nil)
      Chat.new(
        record: r,
        id: Id.new(r.id),
        recipient_token: Chat::Token.new(
          val: r.recipient_token,
          expires_at: r.recipient_token_expires_at
        ),
        messages: r.messages.map { |m|
          map_message(m)
        },
        current_case_id: current_case_id,
      )
    end

    def self.map_message(r)
      Chat::Message.new(
        id: r["id"],
        sender: r["sender"],
        type: r["type"]&.to_sym,
        body: r["body"],
      )
    end
  end
end
