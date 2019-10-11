class Case
  class Repo
    # -- queries --
    # -- queries/one
    def find_one(id)
      record = Case::Record
        .find(id)

      Case.from_record(record)
    end

    def find_one_for_enroller(id, enroller_id)
      record = Case::Record
        .where(enroller_id: enroller_id)
        .pending
        .find(id)

      Case.from_record(record)
    end

    # -- queries/many
    def find_incomplete
      records = Case::Record
        .where(completed_at: nil)
        .includes(:recipient, :enroller)

      records.map do |record|
        Case.from_record(record)
      end
    end

    def find_for_enroller(enroller_id)
      records = Case::Record
        .where(enroller_id: enroller_id)
        .pending
        .includes(:recipient, :enroller)

      records.map do |record|
        Case.from_record(record)
      end
    end
  end
end
