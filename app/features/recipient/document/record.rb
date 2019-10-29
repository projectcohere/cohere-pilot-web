class Recipient
  class Document
    class Record < ApplicationRecord
      self.table_name = :documents

      # -- associations --
      belongs_to(:recipient, class_name: "::Recipient::Record")
      has_one_attached(:file)
    end
  end
end
