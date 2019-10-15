class Recipient < ::Entity
  # -- props --
  prop(:id)
  prop(:name)

  # -- lifetime --
  def initialize(id:, name:)
    @name = name
  end

  # -- factories --
  def self.from_record(record)
    Recipient.new(
      id: record.id,
      name: Name.new(
        first: record.first_name,
        last: record.last_name
      )
    )
  end
end
