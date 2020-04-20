class Program
  class Repo < ::Repo
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
