class Recipient
  # -- lifetime --
  def initialize(name:)
    @name = name
  end

  # -- profile --
  attr_reader(:name)

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
