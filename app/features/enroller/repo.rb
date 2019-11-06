class Enroller
  class Repo < ::Repo
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

    # -- factories --
    def self.map_record(r)
      Enroller.new(
        id: r.id,
        name: r.name
      )
    end
  end
end
