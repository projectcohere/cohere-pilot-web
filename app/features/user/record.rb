class User
  class Record < ApplicationRecord
    include Clearance::User

    # -- config --
    self.table_name = :users

    # -- associations --
    belongs_to(:organization, polymorphic: true, optional: true)
  end
end
