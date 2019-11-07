
class Enroller
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Services.enroller_repo ||= Repo.new
    end

    # -- queries --
    # -- queries/one
    def find(id)
      find_cached(id) do
        record = Enroller::Record
          .find(id)

        entity_from(record)
      end
    end

    def find_default
      find_cached(:default) do
        record = Enroller::Record
          .first

        entity_from(record)
      end
    end

    # -- queries/many
    def find_many(ids)
      ids = ids.uniq

      find_cached(ids.join(",")) do
        records = Enroller::Record
          .where(id: ids)

        entities_from(records)
      end
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
