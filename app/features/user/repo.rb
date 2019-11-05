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
      User.from_record(record)
    end

    private def entities_from(records)
      records.map do |record|
        entity_from(record)
      end
    end
  end
end
