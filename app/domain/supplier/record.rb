class Supplier
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    has_many(:users, as: :organization, class_name: "::User::Record")
  end
end
