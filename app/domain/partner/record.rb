class Partner
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    has_many(:users, class_name: "User::Record", foreign_key: "partner_id")
  end
end
