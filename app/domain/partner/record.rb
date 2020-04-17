class Partner
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    has_many(:users, class_name: "User::Record", foreign_key: "partner_id")
    has_and_belongs_to_many(:programs, class_name: "Program::Record", foreign_key: "partner_id", association_foreign_key: "program_id")

    # -- membership class --
    enum(membership: Membership.keys)
  end
end
