class Stats
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repo.new
    end

    # -- queries --
    def find_current
      case_recs = ::Case::Record
        .where(
          program: Program::Name::Meap,
          status: [::Case::Status::Approved, ::Case::Status::Denied],
        )

      supplier_recs = ::Supplier::Record
        .where(program: Program::Name::Meap)

      return entity_from(case_recs, supplier_recs)
    end

    # -- factories --
    def self.map_record(case_recs, supplier_recs)
      suppliers_by_id = supplier_recs
        .map { |r| map_supplier(r) }
        .each_with_object({}) { |r, h| h[r.id] = r }

      return Stats.new(
        cases: case_recs.map { |r| map_case(r, suppliers_by_id) },
      )
    end

    def self.map_case(r, suppliers_by_id)
      return Case.new(
        supplier: suppliers_by_id[r.supplier_id],
        status: r.status.to_sym,
        created_at: r.created_at,
        completed_at: r.completed_at,
      )
    end

    def self.map_supplier(r)
      return Supplier.new(
        id: r.id,
        name: r.name,
      )
    end
  end
end
