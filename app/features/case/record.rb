class Case
  class Record < ApplicationRecord
    self.table_name = :cases

    # -- associations --
    belongs_to(:recipient, class_name: "Recipient::Record")
  end
end
