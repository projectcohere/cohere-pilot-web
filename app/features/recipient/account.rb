class Recipient
  class Account < Entity
    # -- props --
    prop(:id)

    # -- liftime --
    def initialize(id:)
      @id = id
    end

    # -- factories --
    def self.from_record(record)
      Account.new(
        id: record.id
      )
    end
  end
end
