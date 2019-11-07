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
end
