class Document
  class Record < ApplicationRecord
    self.table_name = :documents

    # -- associations --
    belongs_to(:case, class_name: "::Case::Record")
    has_one_attached(:file)
  end
end
