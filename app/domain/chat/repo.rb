class Chat
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repo.new
    end

    # -- queries --
    # -- queries/one
    def find_by_recipient_token(recipient_token)
      record = Chat::Record
        .where("recipient_token_expires_at >= ?", Time.zone.now)
        .find_by(recipient_token: recipient_token)

      entity_from(record)
    end

    # -- factories --
    def self.map_record(r)
      Chat.new(
        id: Id.new(r.id),
        recipient_token: Chat::Token.new(
          value: r.recipient_token,
          expires_at: r.recipient_token_expires_at
        )
      )
    end
  end
end
