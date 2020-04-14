class Partner
  class Repo < ::Repo
    include Service::Singleton

    # -- lifetime --
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

    def find_cohere
      find_cached(:cohere) do
        record = Partner::Record
          .find_by!(membership: Partner::Membership::Cohere.key)

        entity_from(record)
      end
    end

    def find_dhs
      find_cached(:dhs) do
        record = Partner::Record
          .find_by!(membership: Partner::Membership::Governor.key)

        entity_from(record)
      end
    end

    def find_current_supplier
      current_user = @user_repo.find_current
      if not current_user.role.membership.supplier?
        return nil
      end

      find(current_user.role.partner_id)
    end

    def find_default_enroller
      find_cached(:default_enroller) do
        record = Partner::Record
          .find_by!(membership: Membership::Enroller.key)

        entity_from(record)
      end
    end

    # -- queries/many
    def find_all_by_ids(ids)
      ids = ids.uniq

      find_cached(ids.join(",")) do
        partner_recs = Partner::Record
          .where(id: ids)

        partner_recs.map { |r| entity_from(r) }
      end
    end

    def find_all_suppliers_by_program(program)
      partner_recs = Partner::Record
        .where(membership: Partner::Membership::Supplier.key)
        .where("programs @> '{?}'", program.index)

      partner_recs.map { |r| entity_from(r) }
    end

    # -- factories --
    def self.map_record(r)
      Partner.new(
        id: r.id,
        name: r.name,
        membership: Membership.from_str(r.membership),
        programs: r.programs&.map { |p| Program::Name.from_index(p) },
      )
    end
  end
end
