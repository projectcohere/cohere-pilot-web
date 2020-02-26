class Supplier < ::Entity
  # -- props --
  prop(:id)
  prop(:name)
  prop(:program)

  # -- factories --
  def open_case(enroller, account:, profile:)
    Case.open(
      program: Program::Name::Meap,
      profile: profile,
      enroller: enroller,
      supplier: self,
      supplier_account: account
    )
  end
end
