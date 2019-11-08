class Enroller
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    has_many(:cases, class_name: "::Case::Record")
    has_many(:users, as: :organization, class_name: "::User::Record")
  end
end
