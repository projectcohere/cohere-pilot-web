class Recipient
  class Household
    class Record < ApplicationRecord
      self.table_name = :households

      # -- associations --
      belongs_to(:recipient, class_name: "::Recipient::Record")
    end
  end
end
