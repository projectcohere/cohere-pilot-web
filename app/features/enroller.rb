class Enroller < ::Entity
  # -- props --
  prop(:id)
  prop(:name)

  # -- lifetime --
  define_initialize!

  # -- factories --
  def self.from_record(r)
    Enroller.new(
      id: r.id,
      name: r.name
    )
  end
end
