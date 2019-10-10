class Enroller
  attr_reader(:name)

  # -- lifetime --
  def initialize(name:)
    @name = name
  end

  # -- factories --
  def self.from_record(record)
    Enroller.new(
      name: record.name
    )
  end
end
