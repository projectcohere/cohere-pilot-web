class Document
  # A repo for fetching and updating documents in the database.
  #
  # Note. Document is not an AR, it is part of Case, and should not
  # have a repo. Due to ActiveStorage's awkward attachment API, it's
  # difficult to create Attachments (which would be the AR in this
  # case) outside the context of a Document.
  #
  # Therefore, don't add anything to this class.
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Services.document_repo ||= Repo.new
    end

    # -- queries --
    # -- queries/one
    def find(id)
      record = Document::Record
        .find(id)

      entity_from(record)
    end

    # -- commands --
    def save_attached_file(document)
      if document.record.nil?
        raise "unsaved document can't be updated with a new file!"
      end

      new_file = document.new_file
      if new_file.nil?
        return
      end

      f = new_file
      document.record.file.attach(
        io: f.data,
        filename: f.name,
        content_type: f.mime_type
      )
    end

    # -- factories --
    def self.map_record(r)
      Document.new(
        record: r,
        id: r.id,
        classification: r.classification.to_sym,
        file: r.file,
        source_url: r.source_url
      )
    end
  end
end
