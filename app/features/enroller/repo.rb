class Enroller
  class Repo
    # -- lifetime --
    def self.get
      Repos.enrollers ||= Repo.new
    end

    # -- queries --
    # -- queries/one
    def find_one(id)
      find_cached(id) do
        record = Enroller::Record
          .find(id)

        entity_from(record)
      end
    end

    def find_default
      record = Enroller::Record
        .first

      entity_from(record)
    end

    # -- helpers --
    private def entity_from(record)
      record.nil? ? nil : Repo.map_record(record)
    end

    private def entities_from(records)
      records.map do |record|
        entity_from(record)
      end
    end

    private def find_cached(key, &find)
      @cache ||= {}

      hit = @cache[key]
      if not hit.nil?
        return hit
      end

      @cache[key] = find.()
    end

    # -- factories --
    def self.map_record(r)
      Enroller.new(
        id: r.id,
        name: r.name
      )
    end
  end
end
