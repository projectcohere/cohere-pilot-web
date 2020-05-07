class Program
  class Repo < ::Repo
    include Service

    # -- queries --
    def find(id)
      program_rec = Program::Record
        .find(id)

      return self.class.map_record(program_rec)
    end

    # -- queries/all
    def find_all_by_partner(partner_id)
      program_query = Program::Record
        .active
        .for_partner(partner_id)
        .by_priority

      return program_query.map { |r| self.class.map_record(r) }
    end

    def find_all_available_by_recipient(recipient_id)
      program_query = Program::Record
        .active
        .with_no_case_for_recipient(recipient_id)
        .by_priority

      return program_query.map { |r| self.class.map_record(r) }
    end

    # -- mapping --
    def self.map_record(r)
      return Program.new(
        id: r.id,
        name: r.name,
        contracts: r.contracts.map { |v| Contract.new(variant: v.to_sym) },
        requirements: r.requirements.flat_map { |g, rs| map_requirements(g, rs) },
      )
    end

    def self.map_requirements(group, rs)
      return rs.map do |r|
        Requirement.from_key(r, group: group)
      end
    end
  end
end
