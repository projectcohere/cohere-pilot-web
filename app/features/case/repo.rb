class Case
  class Repo
    # -- queries --
    # -- queries/one
    def find_one(id)
      record = Case::Record
        .find(id)

      entity_from(record)
    end

    def find_one_for_enroller(id, enroller_id)
      record = Case::Record
        .where(enroller_id: enroller_id)
        .pending
        .find(id)

      entity_from(record)
    end

    # -- queries/many
    def find_incomplete
      records = Case::Record
        .where(completed_at: nil)
        .includes(:recipient, :enroller)

      entities_from(records)
    end

    def find_for_enroller(enroller_id)
      records = Case::Record
        .where(enroller_id: enroller_id)
        .pending
        .includes(:recipient, :enroller)

      entities_from(records)
    end

    def find_opened
      records = Case::Record
        .opened
        .includes(:recipient, :enroller)

      entities_from(records)
    end

    private

    def entity_from(record)
      Case.from_record(record)
    end

    def entities_from(records)
      records.map do |record|
        entity_from(record)
      end
    end
  end
end
