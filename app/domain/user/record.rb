class User
  class Record < ::ApplicationRecord
    include Clearance::User

    # -- config --
    set_table_name!

    # -- associations --
    belongs_to(:organization, polymorphic: true, optional: true)
  end
end
