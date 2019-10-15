class Case
  class Record < ::ApplicationRecord
    self.table_name = :cases

    # -- associations --
    belongs_to(:recipient, class_name: "::Recipient::Record")
    belongs_to(:enroller, class_name: "::Enroller::Record")
    belongs_to(:supplier, class_name: "::Supplier::Record")

    # -- status --
    enum(status: %i[opened scorable pending approved rejected])
  end
end
