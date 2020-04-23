class Partner
  class Record < ApplicationRecord
    # -- associations --
    has_many(:users)
    has_and_belongs_to_many(:programs)

    # -- membership class --
    enum(membership: Membership.keys)
  end
end
