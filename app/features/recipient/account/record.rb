class Recipient
  class Account
    class Record < ApplicationRecord
      self.table_name = :accounts

      # -- associations --
      belongs_to(:recipient, class_name: "::Recipient::Record")
      belongs_to(:supplier, class_name: "::Supplier::Record")
    end
  end
end
