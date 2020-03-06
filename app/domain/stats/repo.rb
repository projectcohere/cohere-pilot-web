class Stats
  class Repo < ::Repo
    # -- constants --
    DurationsKey = "cohere--stats/durations".freeze

    # -- lifetime --
    def self.get
      Repo.new
    end

    def initialize(redis: Redis.new)
      @redis = redis
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

      durations_rec = ActiveSupport::JSON
        .decode(@redis.get(DurationsKey) || "{}")

      return entity_from(case_recs, supplier_recs, durations_rec)
    end

    # -- commands --
    def save_durations(durations)
      @redis.set(DurationsKey, durations.to_json)
    end

    # -- factories --
    def self.map_record(case_recs, supplier_recs, durations_rec)
      suppliers_by_id = supplier_recs
        .map { |r| map_supplier(r) }
        .each_with_object({}) { |r, h| h[r.id] = r }

      return Stats.new(
        cases: case_recs.map { |r| map_case(r, suppliers_by_id) },
        durations: durations_rec.then { |r| map_durations(r) },
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

    def self.map_durations(r)
      return Durations.new(
        count: r.dig("count"),
        dhs: Duration.new(
          avg_seconds: r.dig("dhs", "avg_seconds"),
        ),
        enroller: Duration.new(
          avg_seconds: r.dig("enroller", "avg_seconds"),
        ),
        recipient: Duration.new(
          avg_seconds: r.dig("recipient", "avg_seconds"),
        ),
      )
    end
  end
end
