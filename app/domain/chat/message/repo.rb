class Chat
  class Message
    class Repo < ::Repo
      # -- lifetime --
      def self.get
        Repo.new
      end

      # -- queries --
      # -- queries/one
      def find(id)
        message_rec = Chat::Message::Record
          .find(id)

        entity_from(message_rec)
      end

      # -- factories --
      def self.map_record(r)
        Chat::Message.new(
          id: Id.new(r.id),
          sender: r.sender,
          body: r.body,
          chat_id: r.chat_id
        )
      end
    end
  end
end
