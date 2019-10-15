class Recipient < ::Entity
  # -- props --
  prop(:name)

  # -- lifetime --
  def initialize(name:)
    @name = name
  end

  # -- factories --
  def self.from_record(record)
    Recipient.new(
      name: Name.new(
        first: record.first_name,
        last: record.last_name
      )
    )
  end
end
