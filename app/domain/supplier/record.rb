class Supplier
  class Record < ::ApplicationRecord
    self.table_name = :suppliers

    # -- associations --
    has_many(:users, as: :organization, class_name: "::User::Record")
  end
end
