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

        entity_from(message_rec, message_rec.files.blobs)
      end

      # -- queries/many
      def find_many_by_chat_with_attachments(chat_id)
        message_recs = Chat::Message::Record
          .with_attached_files
          .order(created_at: :asc)
          .where(chat_id: chat_id)

        entities_from(message_recs) do |message_rec|
          [message_rec.files.blobs]
        end
      end

      # -- factories --
      def self.map_record(r, attachment_recs = [])
        Chat::Message.new(
          id: Id.new(r.id),
          sender: r.sender,
          body: r.body,
          chat_id: r.chat_id,
          attachments: attachment_recs.to_a
        )
      end
    end
  end
end
