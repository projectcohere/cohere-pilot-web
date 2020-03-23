class Partner
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Services.partner_repo ||= Repo.new
    end

    def initialize(user_repo: User::Repo.get)
      @user_repo = user_repo
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

    def find_current_supplier
      current_user = @user_repo.find_current
      if not current_user.role.supplier?
        return nil
      end

      find(current_user.role.partner_id)
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
    def find_all_by_ids(ids)
      ids = ids.uniq

      find_cached(ids.join(",")) do
        records = Partner::Record
          .where(id: ids)

        entities_from(records)
      end
    end

    def find_all_suppliers_by_program(program)
      partner_recs = Partner::Record
        .where(membership_class: MembershipClass::Supplier)
        .where("programs @> '{?}'", ::Program::Name.index(program))

      return entities_from(partner_recs)
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
