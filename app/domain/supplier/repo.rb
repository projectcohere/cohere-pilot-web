class Supplier
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Services.supplier_repo ||= Repo.new
    end

    def initialize(user_repo: User::Repo.get)
      @user_repo = user_repo
    end

    # -- queries --
    # -- queries/one
    def find_current
      current_user = @user_repo.find_current
      if current_user.role.name != :supplier
        return nil
      end

      find(current_user.role.organization_id)
    end

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
        name: r.name,
        program: r.program.to_sym
      )
    end
  end
end
