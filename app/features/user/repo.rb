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
    def find_for_new_case_notification
      records = User::Record
        .where(organization_type: [:cohere, :dhs])

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
