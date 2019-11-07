class Document
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Services.documents ||= Repo.new
    end

    # -- queries --
    # -- queries/one
    def find(id)
      find_cached(id) do
        record = Document::Record
          .find(id)

        entity_from(record)
      end
    end

    def find_all_for_case(case_id)
      find_cached("case=#{case_id}") do
        records = Document::Record
          .where(case_id: case_id.val)

        entities_from(records)
      end
    end

    # -- commands --
    def save_uploaded(documents)
      if documents.empty?
        return
      end

      records = Document::Record.transaction do
        Document::Record.create!(documents.map { |d|
          { case_id: d.case_id.val, source_url: d.source_url }
        })
      end

      records.each_with_index do |r, i|
        documents[i].did_save(r)
      end
    end

    def save_attached_file(document)
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

    # -- factories --
    def self.map_record(r)
      Document.new(
        record: r,
        id: r.id,
        file: r.file,
        source_url: r.source_url,
        case_id: r.case_id
      )
    end
  end
end
