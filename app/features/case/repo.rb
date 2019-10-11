class Case
  class Repo
    def find_incomplete
      records = Case::Record
        .where(completed_at: nil)
        .includes(:recipient, :enroller)

      records.map do |record|
        Case.from_record(record)
      end
    end

    def find_pending_for_enroller(enroller_id)
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
