class Supplier < ::Entity
  # -- props --
  prop(:id)
  prop(:name)
  props_end!

  # -- factories --
  def open_case(enroller, account:, profile:)
    Case.open(
      account: account,
      profile: profile,
      enroller: enroller,
      supplier: self
    )
  end

  def self.from_record(r)
    Supplier.new(
      id: r.id,
      name: r.name
    )
  end
end
