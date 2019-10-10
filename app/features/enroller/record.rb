class Enroller
  class Record < ApplicationRecord
    self.table_name = :enrollers

    # -- associations --
    has_many(:users, as: :organization, class_name: "User::Record")
  end
end
