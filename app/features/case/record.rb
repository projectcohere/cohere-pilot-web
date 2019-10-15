class Case
  class Record < ::ApplicationRecord
    self.table_name = :cases

    # -- associations --
    belongs_to(:recipient, class_name: "::Recipient::Record")
    belongs_to(:enroller, class_name: "::Enroller::Record")

    # -- properties --
    enum(status: %i[opened scorable pending approved rejected])
  end
end
