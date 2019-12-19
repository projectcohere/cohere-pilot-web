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
    def find_by_recipient_token(recipient_token)
      record = Chat::Record
        .where("recipient_token_expires_at >= ?", Time.zone.now)
        .find_by(recipient_token: recipient_token)

      entity_from(record)
    end

    def find_with_message(id, message_id)
      record = Chat::Record
        .select(Chat::Record.column_names - ["messages"])
        .select("jsonb_build_array(messages->#{message_id}) as messages")
        .where("messages->0 IS NOT NULL")
        .find(id)

      entity_from(record).tap do |chat|
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
    def self.map_record(r)
      Chat.new(
        record: r,
        id: Id.new(r.id),
        recipient_token: Chat::Token.new(
          value: r.recipient_token,
          expires_at: r.recipient_token_expires_at
        ),
        messages: r.messages.map { |m|
          map_message(m)
        },
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
