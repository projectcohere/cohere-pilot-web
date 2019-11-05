class Supplier
  class Repo
    # -- queries --
    # -- queries/one
    def find_one(id)
      record = Supplier::Record
        .find(id)

      entity_from(record)
    end

    # -- helpers --
    private def entity_from(record)
      if record == nil
        return nil
      end

      Supplier.from_record(record)
    end

    private def entities_from(records)
      records.map do |record|
        entity_from(record)
      end
    end
  end
end
