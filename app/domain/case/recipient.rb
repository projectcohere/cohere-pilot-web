class Case
  class Recipient < ::Entity
    prop(:record, default: nil)

    # -- props --
    prop(:id, default: Id::None)
    prop(:profile)
    prop(:household, default: nil)

    # -- commands --
    def add_governor_data(household)
      @household = household
    end

    def add_agent_data(profile, household)
      @profile = profile
      @household = household
    end

    # -- events --
    def did_save(record)
      @id.set(record.id)
      @record = record
    end
  end
end
