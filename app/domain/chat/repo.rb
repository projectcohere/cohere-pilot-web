class Chat
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repo.new
    end

    # -- queries --
    # -- queries/one
    def find_by_remember_token(remember_token)
      record = Chat::Record
        .where("remember_token_expires_at >= ?", Time.zone.now)
        .find_by(remember_token: remember_token)

      entity_from(record)
    end

    # -- factories --
    def self.map_record(r)
      Chat.new(
        id: Id.new(r.id),
        remember_token: Chat::Token.new(
          value: r.remember_token,
          expires_at: r.remember_token_expires_at
        )
      )
    end
  end
end
