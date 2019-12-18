class Chat
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    belongs_to(:recipient, class_name: "::Recipient::Record")
  end
end
