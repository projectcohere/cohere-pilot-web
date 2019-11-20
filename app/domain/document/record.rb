class Document
  class Record < ApplicationRecord
    set_table_name!

    # -- associations --
    belongs_to(:case, class_name: "::Case::Record", touch: true)
    has_one_attached(:file)

    # -- classification --
    enum(classification: %i[unknown contract])
  end
end
