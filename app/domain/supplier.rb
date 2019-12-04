class Supplier < ::Entity
  # -- props --
  prop(:id)
  prop(:name)
  props_end!

  # -- factories --
  def open_case(enroller, profile:, account:)
    Case.open(
      program: Case::Program::Meap,
      profile: profile,
      enroller: enroller,
      supplier: self,
      supplier_account: account
    )
  end
end
