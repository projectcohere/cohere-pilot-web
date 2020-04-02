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
        message_rec = Message::Record
          .find(id)

        return entity_from(message_rec)
      end

      def find_with_attachments(id)
        message_rec = Message::Record
          .joins_attachments
          .find(id)

        return entity_from(message_rec, attachments: message_rec.attachments)
      end

      def find_by_selected_attachment(attachment_id)
        message_rec = Message::Record
          .joins_attachments
          .references(:chat_attachments)
          .where(chat_attachments: { id: attachment_id })
          .first!

        message = entity_from(message_rec, attachments: message_rec.attachments)
          .tap { |m| m.select_attachment(attachment_id) }

        return message
      end

      # -- queries/many
      def find_many_by_chat_with_attachments(chat_id)
        message_recs = Message::Record
          .joins_attachments
          .order(created_at: :asc)
          .where(chat_id: chat_id)

        return message_recs.map { |r| entity_from(r, attachments: r.attachments) }
     end

      # -- factories --
      def self.map_record(r, attachments: [])
        return Message.new(
          id: Id.new(r.id),
          sender: r.sender,
          body: r.body,
          timestamp: r.created_at.to_i,
          attachments: attachments.to_a.map { |r| self.map_attachment(r) },
          chat_id: r.chat_id,
        )
      end

      def self.map_attachment(r)
        return Attachment.new(
          record: r,
          id: Id.new(r.id),
          file: r.file,
          remote_url: r.remote_url,
        )
      end
    end

    # -- scopes --
    class Record
      def self.joins_attachments
        return includes(attachments: :file)
      end
    end
  end
end
