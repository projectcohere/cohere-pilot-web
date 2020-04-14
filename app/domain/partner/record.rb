class Partner
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    has_many(:users, class_name: "User::Record", foreign_key: "partner_id")

    # -- membership class --
    enum(membership: Membership.keys)
  end
end
