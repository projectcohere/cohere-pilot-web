class Recipient
  class Document
    class Repo
      # -- queries --
      # -- queries/one
      def find_one(id)
        record = Document::Record
          .find(id)

        entity_from(record)
      end

      # -- commands --
      def save_new_file(document)
        if document.record.nil?
          raise "unsaved document can't be updated with a new file!"
        end

        new_file = document.new_file
        if new_file.nil?
          return
        end

        document.record.file.attach(
          io: new_file.data,
          filename: new_file.name,
          content_type: new_file.mime_type
        )
      end

      # -- helpers --
      private def entity_from(record)
        record.nil? ? nil : Repo.map_record(record)
      end

      # -- factories --
      def self.map_record(r)
        Document.new(
          record: r,
          id: r.id,
          file: r.file,
          source_url: r.source_url
        )
      end
    end
  end
end
