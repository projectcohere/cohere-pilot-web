class Enroller
  class Repo
    # -- queries --
    # -- queries/one
    def find_default
      record = Enroller::Record
        .first

      entity_from(record)
    end

    # -- helpers --
    private def entity_from(record)
      if record == nil
        return nil
      end

      Enroller.from_record(record)
    end

    private def entities_from(records)
      records.map do |record|
        entity_from(record)
      end
    end
  end
end
