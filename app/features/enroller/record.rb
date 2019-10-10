class Enroller
  class Record < ApplicationRecord
    self.table_name = :enrollers

    # -- associations --
    has_many(:users, as: :organization)
  end
end
