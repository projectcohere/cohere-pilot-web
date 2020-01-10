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

      def find_with_attachments(id)
        message_rec = Chat::Message::Record
          .with_attached_files
          .find(id)

        entity_from(message_rec, message_rec.files.attachments)
      end

      # -- factories --
      def self.map_record(r, attachment_recs = [])
        Chat::Message.new(
          id: Id.new(r.id),
          sender: r.sender,
          body: r.body,
          chat_id: r.chat_id,
          attachments: attachment_recs
        )
      end
    end
  end
end
