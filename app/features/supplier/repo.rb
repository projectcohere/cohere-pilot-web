class Supplier
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repos.suppliers ||= Repo.new
    end

    # -- queries --
    # -- queries/one
    def find_one(id)
      find_cached(id) do
        record = Supplier::Record
          .find(id)

        entity_from(record)
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
