class Supplier < ::Entity
  # -- props --
  prop(:id)
  prop(:name)

  # -- lifetime --
  def initialize(id:, name:)
    @id = id
    @name = name
  end

  # -- factories --
  def self.from_record(r)
    Supplier.new(
      id: r.id,
      name: r.name
    )
  end
end
