class Supplier
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Services.suppliers ||= Repo.new
    end

    # -- queries --
    # -- queries/one
    def find(id)
      find_cached(id) do
        record = Supplier::Record
          .find(id)

        entity_from(record)
      end
    end

    # -- queries/many
    def find_many(ids)
      ids = ids.uniq

      find_cached(ids.join(",")) do
        records = Supplier::Record
          .where(id: ids)

        entities_from(records)
      end
    end

    # -- factories --
    def self.map_record(r)
      Supplier.new(
        id: r.id,
        name: r.name
      )
    end
  end
end
