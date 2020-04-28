class Partner
  class Record < ApplicationRecord
    # -- associations --
    has_many(:users)
    has_and_belongs_to_many(:programs)

    # -- membership class --
    enum(membership: Membership.keys)

    # -- scopes --
    def self.with_membership(membership)
      return where(membership: membership.key)
    end

    def self.with_program(program_id)
      scope = self
        .includes(:programs)
        .where(
          partners_programs: {
            program_id: program_id
          }
        )

      return scope
    end
  end
end
