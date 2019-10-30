class Supplier < ::Entity
  # -- props --
  prop(:id)
  prop(:name)
  props_end!

  # -- factories --
  def self.from_record(r)
    Supplier.new(
      id: r.id,
      name: r.name
    )
  end
end
