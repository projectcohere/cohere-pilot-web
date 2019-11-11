class Recipient
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    has_many(:cases, foreign_key: "recipient_id", class_name: "::Case::Record")
  end
end
