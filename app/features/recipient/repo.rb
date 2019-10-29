class Recipient
  class Repo
    # -- queries --
    # -- queries/one
    def find_one_by_phone_number(phone_number)
      record = Recipient::Record
        .find_by(phone_number: phone_number)

      entity_from(record)
    end

    # -- commands --
    def save_new_documents(recipient)
      if recipient.record.nil?
        raise "unsaved recipient can't be updated with new doucments!"
      end

      documents = recipient.new_documents
      if documents.empty?
        return
      end

      records = recipient.record.documents.create!(documents.map { |d|
        { source_url: d.source_url }
      })

      records.each_with_index do |r, i|
        documents[i].did_save(r)
      end
    end

    # -- helpers --
    private def entity_from(record)
      if record == nil
        return nil
      end

      Recipient.from_record(record)
    end

    private def entities_from(records)
      records.map do |record|
        entity_from(record)
      end
    end
  end
end
