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

        entity_from(message_rec, attachments: message_rec.files.blobs)
      end

      # -- queries/many
      def find_many_by_chat_with_attachments(chat_id)
        message_recs = Chat::Message::Record
          .with_attached_files
          .order(created_at: :asc)
          .where(chat_id: chat_id)

        message_recs.map { |r| entity_from(r, attachments: r.files.blobs) }
     end

      # -- factories --
      def self.map_record(r, attachments: [])
        Chat::Message.new(
          id: Id.new(r.id),
          sender: r.sender,
          body: r.body,
          timestamp: r.created_at.to_i,
          attachments: attachments.to_a,
          chat_id: r.chat_id,
        )
      end
    end
  end
end
