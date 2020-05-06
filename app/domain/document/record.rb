class Document
  class Record < ApplicationRecord
    # -- associations --
    belongs_to(:case, touch: true)
    has_one_attached(:file)

    # -- classification --
    enum(classification: %i[unknown contract])
  end
end
