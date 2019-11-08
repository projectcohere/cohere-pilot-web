class Document
  class Record < ApplicationRecord
    set_table_name!

    # -- associations --
    belongs_to(:case, class_name: "::Case::Record")
    has_one_attached(:file)
  end
end
