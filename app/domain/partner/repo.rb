class Partner
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Services.partner_repo ||= Repo.new
    end

    # -- queries --
    # -- queries/one
    def find(id)
      find_cached(id) do
        record = Partner::Record
          .find(id)

        entity_from(record)
      end
    end

    def find_default_enroller
      find_cached(:default_enroller) do
        record = Partner::Record
          .where(membership_class: MembershipClass::Enroller)
          .first

        entity_from(record)
      end
    end

    # -- queries/many
    def find_many(ids)
      ids = ids.uniq

      find_cached(ids.join(",")) do
        records = Partner::Record
          .where(id: ids)

        entities_from(records)
      end
    end

    # -- factories --
    def self.map_record(r)
      Partner.new(
        id: r.id,
        name: r.name,
        membership_class: r.membership_class&.to_sym
      )
    end
  end
end
