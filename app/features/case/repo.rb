class Case
  class Repo
    def find_incomplete
      records = Record
        .where(completed_at: nil)
        .includes(:recipient)

      records.map do |record|
        Case.from_record(record)
      end
    end
  end
end
