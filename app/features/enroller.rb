class Enroller < Entity
  prop(:id)
  prop(:name)

  # -- lifetime --
  def initialize(id:, name:)
    @id = id
    @name = name
  end

  # -- factories --
  def self.from_record(record)
    Enroller.new(
      id: record.id,
      name: record.name
    )
  end
end
