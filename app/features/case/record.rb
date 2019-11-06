class Case
  class Record < ::ApplicationRecord
    self.table_name = :cases

    # -- associations --
    belongs_to(:recipient, class_name: "::Recipient::Record")
    belongs_to(:enroller, class_name: "::Enroller::Record")
    belongs_to(:supplier, class_name: "::Supplier::Record")
    has_many(:documents, foreign_key: "case_id", class_name: "::Document::Record")

    # -- status --
    enum(status: %i[opened pending submitted approved rejected])
  end
end
