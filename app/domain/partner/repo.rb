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
      return find_cached(id) do
        record = Partner::Record
          .find(id)

        entity_from(record)
      end
    end

    def find_cohere
      return find_cached(:cohere) do
        record = Partner::Record
          .find_by!(membership: Partner::Membership::Cohere.key)

        entity_from(record)
      end
    end

    def find_dhs
      return find_cached(:dhs) do
        record = Partner::Record
          .find_by!(membership: Partner::Membership::Governor.key)

        entity_from(record)
      end
    end

    def find_default_enroller
      return find_cached(:default_enroller) do
        record = Partner::Record
          .find_by!(membership: Membership::Enroller.key)

        entity_from(record)
      end
    end

    # -- queries/many
    def find_all_by_ids(ids)
      ids = ids.uniq

      return find_cached(ids.join(",")) do
        partner_recs = Partner::Record
          .where(id: ids)

        partner_recs.map { |r| entity_from(r) }
      end
    end

    def find_all_suppliers_by_program(program_id)
      partner_recs = Partner::Record
        .includes(:programs)
        .where(
          membership: Partner::Membership::Supplier.key,
          partners_programs: {
            program_id: program_id
          }
        )

      return partner_recs.map { |r| entity_from(r) }
    end

    # -- factories --
    def self.map_record(r)
      return Partner.new(
        id: r.id,
        name: r.name,
        membership: Membership.from_key(r.membership),
        programs: r.programs.map { |r| Program::Repo.map_record(r) },
      )
    end
  end
end
