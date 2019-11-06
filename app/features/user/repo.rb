class User
  class Repo
    # -- queries --
    # -- queries/one
    def find_one(id)
      record = User::Record
        .find(id)

      entity_from(record)
    end

    # -- queries/many
    def find_opened_case_contributors
      records = User::Record
        .where(organization_type: [:cohere, :dhs])

      entities_from(records)
    end

    def find_submitted_case_contributors(enroller_id)
      records = User::Record
        .where(
          organization_type: Enroller::Record.name,
          organization_id: enroller_id
        )

      entities_from(records)
    end

    # -- helpers --
    private def entity_from(record)
      record.nil? ? nil : Repo.map_record(record)
    end

    private def entities_from(records)
      records.map do |record|
        entity_from(record)
      end
    end

    # -- factories --
    def self.map_record(r)
      # parse role from org type. if the user has an org with
      # an associated record it will be the record's class name.
      role, org = case r.organization_type
      when "cohere"
        [:cohere, nil]
      when "dhs"
        [:dhs, nil]
      when Enroller::Record.to_s
        [:enroller, Enroller::Repo.map_record(r.organization)]
      when Supplier::Record.to_s
        [:supplier, Supplier::Repo.map_record(r.organization)]
      end

      # create entity
      User.new(
        id: r.id,
        email: r.email,
        role: role,
        organization: org
      )
    end
  end
end
