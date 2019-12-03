class Supplier < ::Entity
  # -- props --
  prop(:id)
  prop(:name)
  props_end!

  # -- factories --
  def open_case(enroller, account:, profile:)
    Case.open(
      program: Case::Program::Meap,
      account: account,
      profile: profile,
      enroller: enroller,
      supplier: self
    )
  end
end
